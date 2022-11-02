# frozen_string_literal: true

class TwitterSearcher
  class Result
    attr_reader :twitter_search_condition
    attr_accessor :data

    delegate :operator, to: :twitter_search_condition

    def initialize(twitter_search_condition, data = nil)
      @twitter_search_condition = twitter_search_condition
      @data = data || []
    end

    def calc(other_result)
      @data =
        case other_result.operator
        when "-"
          reject(other_result.data.pluck("username"))
        when "&"
          select(other_result.data.pluck("username"))
        end
    end

  
    def reject(other_usernames)
      data.reject { other_usernames.include?_1["username"] }
    end

    def select(other_usernames)
      data.select { other_usernames.include?_1["username"] }
    end
  end

  attr_reader :result, :user

  def initialize(twitter_search_condition, user)
    @twitter_search_condition = twitter_search_condition
    @access_token = user.twitter_access_token
    @refresh_token = user.twitter_refresh_token
    @fetched_access_token_at = user.fetched_access_token_at
    @user = user
  end

  # TODO: 引数の形式チェックとかやるかどうか考える。ひとまずは、正しい引数が渡されることを期待する
  # @param [Hash] condition
  def search_users(&block)
    case @twitter_search_condition.search_type
    when "liked_in_the_last_month", "not_liked_in_the_last_month"
      search_liking_users(1.month, &block)
    when "liked_in_the_last_two_month", "not_liked_in_the_last_two_month"
      search_liking_users(2.months, &block)
    when "liked_in_the_last_three_month", "not_liked_in_the_last_three_month"
      search_liking_users(3.months, &block)
    when "following", "not_following"
      search_followed_users(&block)
    when "not_following_current_user"
      search_current_user_following(&block)
    else
      []
    end
  end

  private

  def search_current_user_following
    current_user_data = client.fetch_users_me["data"]
    target_id = current_user_data["id"]
    target_folling_count = current_user_data.dig("public_metrics", "following_count")

    next_token = nil
    following_users = []
    result = Result.new(@twitter_search_condition)
    loop do
      update_client_access_token_if_needed!

      res = client.fetch_following_users_by(user_id: target_id, next_token: next_token)
      following_users = res["data"]
      result.data += res["data"]

      next_token = res.dig("meta", "next_token")
      progress_rate = 0# next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

      yield(Result.new(@twitter_search_condition, following_users), progress_rate) if block_given?

      break unless next_token
    end

    result
  end

  def search_following_users
    target_user = client.fetch_user_by(@twitter_search_condition.content)["data"]
    target_id = target_user["id"]
    target_follower_count = target_user.dig("public_metrics", "followers_count")

    next_token = nil
    followed_users = []
    result = Result.new(@twitter_search_condition)
    loop do
      update_client_access_token_if_needed!

      res = client.fetch_followed_users_by(user_id: target_id, next_token: next_token)
      followed_users = res["data"]
      result.data += res["data"]

      next_token = res.dig("meta", "next_token")
      progress_rate = 0# next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

      yield(Result.new(@twitter_search_condition, followed_users), progress_rate) if block_given?

      break unless next_token
    end

    result
  end

  def search_liking_users(limit)
    # @twitter_search_condition#content には、ユーザーのプロフィールurlが入っている想定
    target_user_id = client.fetch_user_by(@twitter_search_condition.content).dig("data", "id")
    tweets = []
    next_token = nil
    100.times do
      update_client_access_token_if_needed!

      res = client.fetch_tweets_by(user_id: target_user_id, limit: limit, next_token: next_token)
      tweets.concat(res["data"]) if res["data"].present?

      next_token = res.dig("meta", "next_token")
      break if next_token.blank?
    end
    
    # ツイートごとに検索する感じ。
    next_token = nil
    result = Result.new(@twitter_search_condition)
    liking_users = []
    tweets.each.with_index(1) do |tweet, i|
      update_client_access_token_if_needed!

      res = client.fetch_liking_users_by(tweet_id: tweet["id"], next_token: next_token)

      if res["data"].present?
        liking_users |= res["data"].select { result.data.pluck("username").exclude?(_1["username"]) }
        result.data |= liking_users
      end

      next_token = res.dig("meta", "next_token")
      if next_token && tweet.dig("public_metrics", "like_count") >= 100
        redo
      end

      Rails.logger.info "#{i}/#{tweets.count}件目の取得が終了"

      progress_rate = 0#(i/tweets.size.to_f) * 100
      yield(Result.new(@twitter_search_condition, liking_users), progress_rate) if block_given?
      liking_users = []
    end

    result
  end

  def search_followed_users
    target_user = client.fetch_user_by(@twitter_search_condition.content)["data"]
    target_id = target_user["id"]
    target_follower_count = target_user.dig("public_metrics", "followers_count")

    next_token = nil
    followed_users = []
    result = Result.new(@twitter_search_condition)
    loop do
      update_client_access_token_if_needed!

      res = client.fetch_followed_users_by(user_id: target_id, next_token: next_token)
      followed_users = res["data"]
      result.data += res["data"]

      next_token = res.dig("meta", "next_token")
      progress_rate = 0# next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

      yield(Result.new(@twitter_search_condition, followed_users), progress_rate) if block_given?

      break unless next_token
    end

    result
  end

  def client
    @client ||= TwitterApiClient.new(access_token: @access_token, refresh_token: @refresh_token)
  end

  def update_client_access_token_if_needed!
    if @fetched_access_token_at < Time.now.ago(1.hour)
      @client = client.refresh_access_token!
      @fetched_access_token_at = Time.now

      user.update(
        twitter_access_token: @client.access_token,
        twitter_refresh_token: @client.refresh_token,
        fetched_access_token_at: @fetched_access_token_at
      )
    end
  end
end
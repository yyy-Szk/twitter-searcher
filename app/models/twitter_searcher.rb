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

  attr_reader :result

  def initialize(twitter_search_condition, access_token)
    @twitter_search_condition = twitter_search_condition
    @access_token = access_token
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
    else
      []
    end
  end

  private

  def search_liking_users(limit)
    # @twitter_search_condition#content には、ユーザーのプロフィールurlが入っている想定
    target_user_id = client.fetch_user_by(@twitter_search_condition.content).dig("data", "id")
    tweets = client.fetch_tweets_by(user_id: target_user_id, limit: limit)["data"] || []

    # ツイートごとに検索する感じ。
    next_token = nil
    result = Result.new(@twitter_search_condition)
    tweets.each.with_index(1) do |tweet, i|
      res = client.fetch_liking_users_by(tweet_id: tweet["id"], next_token: next_token)

      if liking_users = res["data"].presence
        liking_users -= result.data
        result.data |= liking_users
      end

      next_token = res.dig("meta", "next_token")
      if next_token && tweet.dig("public_metrics", "like_count") >= 100
        redo
      end

      Rails.logger.info "#{i}/#{tweets.count}件目の取得が終了"

      progress_rate = 0#(i/tweets.size.to_f) * 100
      yield(Result.new(@twitter_search_condition, liking_users), progress_rate) if block_given? && liking_users.present?
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
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
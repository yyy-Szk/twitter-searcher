# frozen_string_literal: true

class TwitterSearcher
  class Result
    attr_reader :condition
    attr_accessor :data

    delegate :operator, to: :@twitter_search_condition

    def initialize(twitter_search_condition)
      @twitter_search_condition = twitter_search_condition
      @data = []
    end

    def calc(other_result)
      @data = @data.send(other_result.operator, other_result.data)
    end
  end

  # TODO: localeかなんかで、英語で設定 => 日本語変換を行う
  # USER_SEARCH_TYPES = { "最近いいねされたユーザー": 0 }.freeze
  USER_SEARCH_TYPES = {
    "直近1ヶ月にいいねしたユーザー": 0,
    "直近2ヶ月にいいねしたユーザー": 1,
    "直近3ヶ月にいいねしたユーザー": 2,
    "直近1ヶ月にいいねしていないユーザー": 3,
    "直近2ヶ月にいいねしていないユーザー": 4,
    "直近3ヶ月にいいねしていないユーザー": 5,
    "フォローしているユーザー": 6,
    "フォローしていないユーザー": 7
  }.freeze

  class << self
    def search_types_for_find
      types = USER_SEARCH_TYPES.deep_dup
      %i[
          直近1ヶ月にいいねしていないユーザー 直近2ヶ月にいいねしていないユーザー
          直近3ヶ月にいいねしていないユーザー フォローしていないユーザー
      ].each do
        types.delete(_1)
      end

      types
    end

    def search_types_for_narrow_down
      USER_SEARCH_TYPES
    end
  end

  attr_reader :result

  def initialize(twitter_search_condition, access_token)
    @twitter_search_condition = twitter_search_condition
    # @search_type = search_type
    # @search_condition = search_condition
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
        result.data |= liking_users
      end

      next_token = res.dig("meta", "next_token")
      if next_token && tweet.dig("public_metrics", "like_count") >= 100
        redo
      end

      Rails.logger.info "#{i}/#{tweets.count}件目の取得が終了"

      progress_rate = (i/tweets.size.to_f) * 100
      yield(result, progress_rate) if block_given? && liking_users.present?
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
      followed_users += res["data"]
      result.data += res["data"]

      next_token = res.dig("meta", "next_token")
      progress_rate = next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

      yield(result, progress_rate) if block_given?

      break unless next_token
    end

    result
  end

  def client
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
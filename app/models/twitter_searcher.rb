# frozen_string_literal: true

class TwitterSearcher
  # TODO: localeかなんかで、英語で設定 => 日本語変換を行う
  # USER_SEARCH_TYPES = { "最近いいねされたユーザー": 0 }.freeze
  USER_SEARCH_TYPES = { "最近いいねしたユーザー": 0, "フォローしているユーザー": 1 }.freeze

  class << self
    def search_types
      USER_SEARCH_TYPES
    end
  end

  attr_reader :results

  def initialize(search_type, search_condition, access_token)
    @search_type = search_type
    @search_condition = search_condition
    @access_token = access_token
  end

  # TODO: 引数の形式チェックとかやるかどうか考える。ひとまずは、正しい引数が渡されることを期待する
  def search_users(&block)
    @results ||= begin
      case @search_type
      when "0" # 最近いいねされたユーザー
        search_liking_users(&block)
      when "1" # フォローしているユーザー
        search_followed_users(&block)
      else
        []
      end
    end
  end

  private

  def search_liking_users
    # @search_condition には、ユーザーのプロフィールurlが入っている想定
    target_user_id = client.fetch_user_by(@search_condition).dig("data", "id")
    tweets = client.fetch_tweets_by(user_id: target_user_id)["data"]

    # ツイートごとに検索する感じ。
    users = []
    next_token = nil
    tweets.each.with_index(1) do |tweet, i|
      res = client.fetch_liking_users_by(tweet_id: tweet["id"], next_token: next_token)

      if liking_users = res["data"].presence
        users |= liking_users
      end

      next_token = res.dig("meta", "next_token")
      if next_token && tweet.dig("public_metrics", "like_count") >= 100
        redo
      end

      Rails.logger.info "#{i}/#{tweets.count}件目の取得が終了"


      progress_rate = (i/tweets.size.to_f) * 100
      yield(progress_rate, users) if block_given?
    end

    users
  end

  def search_followed_users
    target_user = client.fetch_user_by(@search_condition)["data"]
    target_id = target_user["id"]
    target_follower_count = target_user.dig("public_metrics", "followers_count")

    next_token = nil
    followed_users = []
    loop do
      res = client.fetch_followed_users_by(user_id: target_id, next_token: next_token)
      followed_users += res["data"]

      next_token = res.dig("meta", "next_token")
      progress_rate = next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

      yield(progress_rate, followed_users) if block_given?

      break unless next_token
    end

    followed_users
  end

  def client
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
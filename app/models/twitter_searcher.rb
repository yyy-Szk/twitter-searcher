# frozen_string_literal: true

class TwitterSearcher
  # TODO: localeかなんかで、英語で設定 => 日本語変換を行う
  USER_SEARCH_TYPES = { "最近いいねしたユーザー": 0, "フォローしているユーザー": 1 }.freeze

  class << self
    def search_types
      USER_SEARCH_TYPES
    end
  end

  def initialize(access_token:)
    @access_token = access_token
  end

  # TODO: 引数の形式チェックとかやるかどうか考える。ひとまずは、正しい引数が渡されることを期待する
  def search_users(conditions)
    users = []
    conditions.each do |_, condition|
      result = 
        case condition["search_type"]
        when "0"
          # content には、ユーザーのurlが入っている。いかでidだけ取り出す
          # "https://twitter.com/somonsism".sub("https://twitter.com/", "").sub(/(\?.*)?$/, "")
          target_username = condition[:content].sub("https://twitter.com/", "").sub(/(\?.*)?$/, "")
          target_user_id = client.fetch_user_by(user_name: target_username).dig("data", "id")
          search_liking_users_by_user(id: target_user_id)
        else []
        end
      users += result
    end

    users
  end

  # とりあえず、75ツイート分にしておく。バズったツイート（ここでは100いいね以上をバズりとする）とかはキリがないし、取れる情報も少なそう。
  # こいつらは、必ずusersの配列を返すようにする。
  # 最初は300ツイートまでとかにしようと思ったけど、リクエスト制限がきついので、とりあえず75ツイートまでにする。
  # んで、ツイートにつき最大100人まで取ってくるようにする。
  def search_liking_users_by_user(id:)
    tweets = client.fetch_tweets_by(user_id: id)["data"]

    users = []
    tweets.each do |tweet|
      res = client.fetch_liking_users_by(tweet_id: tweet["id"])
      p res
      if liking_users = res["data"]
        users += liking_users
      end
    end

    users
  end

  def search_liking_users_by_tweet(id:)
    client.fetch_liking_users_by(tweet_id: id)["data"]
  end

  # こいつらは、必ずusersの配列を返すようにする。
  def search_followed_users_by_user(id:)
    client.fetch_followed_users_by(user_id: id)["data"]
  end

  # usersのうち、該当のユーザーをフォローしている人だけを抽出
  # def select_following_user_by(users:, user_id:)
  #   target_user_followers = client.fetch_followed_users_by(user_id: user_id)["data"]

  # end

  private

  def client
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
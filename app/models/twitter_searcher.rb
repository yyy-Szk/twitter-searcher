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

  # def search_users(seaech_type, content)
  #   case seaech_type
  #   in 0 search_liking_users_by(tweet_id: )
  #   in 1 search_following_users_by(user_id: )
  #   end
  # end

  # def fetch_liking_users_from_user_tweets_by(id:)
  #   tweets = fetch_tweets_by(use_id: id)["data"]

  #   liking_users = []
  #   tweets.each do |tweet|
  #     # liking_users += fetch_liking_users_by(tweet_id: tweet["id"])["data"]
  #     res_data = fetch_liking_users_by(tweet_id: tweet["id"])["data"]
  #     p "-----"
  #     p res_data
  #     p "-----"
  #     liking_users += res_data if res_data
  #   end

  #   liking_users
  # end


  # こいつらは、必ずusersの配列を返すようにする。
  def search_liking_users_by_user(id:)
    tweets = []
    next_token = nil
    i = 1
    loop do
      i += 1
      p next_token
      res = client.fetch_tweets_by(user_id: id, next_token: next_token)
      tweets += res["data"]
      p res
      break i == 10
      # break unless next_token = res["meta"]["next_token"]
    end
    
    p tweets
  end

  def search_liking_users_by_tweet(id:)
    response = client.fetch_liking_users_by(tweet_id: id)

  end

  # こいつらは、必ずusersの配列を返すようにする。
  def search_followed_users_by_user(id:)

  end

  # こいつらは、必ずusersの配列を返すようにする。

  private

  def client
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
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

  def initialize(result, access_token)
    @result = result
    @access_token = access_token
  end

  # TODO: 引数の形式チェックとかやるかどうか考える。ひとまずは、正しい引数が渡されることを期待する
  def search_users(conditions)
    # users = []
    conditions.each do |_, condition|
      next if condition[:content].blank?

      result = 
        case condition["search_type"]
        when "0"
          # content には、ユーザーのurlが入っている。いかでidだけ取り出す
          target_user_id = client.fetch_user_by(target_username).dig("data", "id")
          search_liking_users_by_user(id: target_user_id)
        else []
        end
      # if i == 1
      #   users += result
      # else
      #   users = users & result
      # end
    end
    # users
  end

  def search_liking_users_case(conditions, narrow_down_conditions)
    conditions.each do |_, condition|
      next if condition[:content].blank?

      # twitter-url
      target_user_id = client.fetch_user_by(condition[:content]).dig("data", "id")
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

        # ここで絞り込む。
        # フォロワー一覧を持ってきて、
        next_token_2 = nil
        narrow_down_conditions.each do |_, narrow_down_condition|
          case narrow_down_condition["type"]
          when "0"
            users
          when "1"
            @followed_users ||= begin
              target_user_id = client.fetch_user_by(narrow_down_condition[:content]).dig("data", "id")
              next_token_2 = nil
              followed_users = []
              loop do
                res = client.fetch_followed_users_by(user_id: target_user_id, next_token: next_token_2)
                followed_users += res["data"]
                next_token_2 = res.dig("meta", "next_token")

                break unless next_token_2
              end

              followed_users
            end
          end
        end
        users &= @followed_users

        p "====================="
        p "#{i}個め終わり"
        p "====================="
        next_token = nil
        progress_rate = (i/tweets.size.to_f) * 100
        update_result_payload(progress_rate, users)   
      end
    end
  end

  def search_liking_users_by_user(id:)
    tweets = client.fetch_tweets_by(user_id: id)["data"]

    users = []
    next_token = nil
    p "====================="
    p "ツイート数", tweets.count
    p "====================="
    tweets.each.with_index(1) do |tweet, i|
      break if i == 10
      res = client.fetch_liking_users_by(tweet_id: tweet["id"], next_token: next_token)

      if liking_users = res["data"].presence
        users |= liking_users
      end

      next_token = res.dig("meta", "next_token")
      if next_token && tweet.dig("public_metrics", "like_count") >= 100
        
        p "====================="
        p "redo!"
        p "====================="
        redo
      end
      p "====================="
      p "#{i}個め終わり"
      p "====================="
      next_token = nil
      update_result_payload(progress_rate, users)
    end

    users
  end
  # ==========


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

  def update_result_payload(progress_rate, users)
    @result.update(progress_rate: progress_rate, payload: users)
  end

  def client
    @_client ||= TwitterApiClient.new(access_token: @access_token)
  end
end
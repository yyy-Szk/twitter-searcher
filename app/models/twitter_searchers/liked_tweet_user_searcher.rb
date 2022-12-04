# frozen_string_literal: true

module TwitterSearchers
  class LikedTweetUserSearcher < TwitterSearcher
    def search
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
        fetched_users = res["data"].select { result.data.pluck("id").exclude?(_1["id"]) }

        if fetched_users.present?
          liking_users += fetched_users
          result.data += fetched_users
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

    private

    def limit
      twitter_search_condition.num_of_days.days
    end
  end
end

# frozen_string_literal: true

module TwitterSearchers
  class TimelineSearcher < TwitterSearcher
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

      sort_tweets!(tweets)
      result = Result.new(@twitter_search_condition, tweets)
      progress_rate = 0

      yield(result, progress_rate) if block_given?

      result
    end

    private

    def limit
      twitter_search_condition.num_of_days.days
    end

    # resultクラスにソート用メソッドを持たせるほうがいいかも??
    def sort_tweets!(result_data)
      result_data.sort_by! do
        [
          -_1.dig("public_metrics", "like_count"),
          -_1.dig("public_metrics", "retweet_count"),
          -_1.dig("public_metrics", "quote_count"),
          -_1.dig("public_metrics", "impression_count"),
          -_1.dig("public_metrics", "reply_count")
        ]
      end
    end
  end
end
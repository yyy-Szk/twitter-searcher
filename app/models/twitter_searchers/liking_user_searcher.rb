# frozen_string_literal: true

module TwitterSearchers
  class LikingUserSearcher < TwitterSearcher
    def search
      # @twitter_search_condition#content には、ユーザーのプロフィールurlが入っている想定
      target_user_id = client.fetch_user_by(@twitter_search_condition.content).dig("data", "id")
      tweets = []
      next_token = nil
      target_date = Time.zone.now.ago(limit)
      100.times do
        update_client_access_token_if_needed!

        res = client.fetch_liking_tweets_by(user_id: target_user_id, next_token: next_token)
        fetched_tweets = res["data"].select { _1["created_at"] > target_date }

        tweets.concat(fetched_tweets) if fetched_tweets.present?

        next_token = res.dig("meta", "next_token")
        break if next_token.blank? || fetched_tweets.size != 100
      end

      # ツイートごとに検索する感じ。
      next_token = nil
      result = Result.new(@twitter_search_condition)
      liking_users = []
      tweets.pluck("author_id").each_slice(100).with_index(1) do |user_ids, i|
        update_client_access_token_if_needed!

        fetched_users = 
          user_ids
            .map { client.fetch_user_by_id(_1)["data"] }
            .inject([]) do |result, user|
              result << user if result.pluck("id").exclude?(user["id"])
              result
            end
        result.data += fetched_users.reject { result.data.pluck("id").include?(_1) }

        Rails.logger.info "いいねしたユーザー取得中"
        progress_rate = 0#(i/tweets.size.to_f) * 100
        yield(Result.new(@twitter_search_condition, fetched_users), progress_rate) if block_given?
      end

      result
    end

    private

    def limit
      twitter_search_condition.num_of_days.days
    end
  end
end

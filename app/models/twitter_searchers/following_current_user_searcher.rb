# frozen_string_literal: true

module TwitterSearchers
  class FollowingCurrentUserSearcher < TwitterSearcher
    # TODO: メソッド切り出し
    def search
      current_user_data = client.fetch_users_me["data"]
      target_id = current_user_data["id"]
      target_folling_count = current_user_data.dig("public_metrics", "following_count")

      next_token = nil
      following_users = []
      result = Result.new(twitter_search_condition)
      loop do
        update_client_access_token_if_needed!

        res = client.fetch_following_users_by(user_id: target_id, next_token: next_token)
        following_users = res["data"]
        result.data += res["data"]

        next_token = res.dig("meta", "next_token")
        progress_rate = 0# next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

        yield(Result.new(twitter_search_condition, following_users), progress_rate) if block_given?

        break unless next_token
      end

      result
    end
  end
end

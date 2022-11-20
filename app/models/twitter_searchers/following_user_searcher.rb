# frozen_string_literal: true

module TwitterSearchers
  class FollowingUserSearcher < TwitterSearcher
    # TODO: メソッド切り出し
    def search
      target_user = client.fetch_user_by(@twitter_search_condition.content)["data"]
      target_id = target_user["id"]
      target_follower_count = target_user.dig("public_metrics", "followers_count")

      next_token = nil
      followed_users = []
      result = Result.new(@twitter_search_condition)
      loop do
        update_client_access_token_if_needed!

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
  end
end

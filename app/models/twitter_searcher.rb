# frozen_string_literal: true

class TwitterSearcher
  class Result
    attr_reader :twitter_search_condition
    attr_accessor :data

    def initialize(twitter_search_condition, data = nil)
      @twitter_search_condition = twitter_search_condition
      @data = data || []
    end

    def narrowing(other_result)
      @data = other_result.twitter_search_condition.narrowing(data, other_result.data)
    end
  end

  attr_reader :result, :user, :twitter_search_condition

  def initialize(twitter_search_condition)
    @twitter_search_condition = twitter_search_condition
    @user = twitter_search_condition.user
    @access_token = @user.twitter_access_token
    @refresh_token = @user.twitter_refresh_token
    @fetched_access_token_at = @user.fetched_access_token_at
  end

  def search(&block)
    raise NotImplementedError
  end

  private


  # def search_following_users
  #   target_user = client.fetch_user_by(@twitter_search_condition.content)["data"]
  #   target_id = target_user["id"]
  #   target_follower_count = target_user.dig("public_metrics", "followers_count")

  #   next_token = nil
  #   followed_users = []
  #   result = Result.new(@twitter_search_condition)
  #   loop do
  #     update_client_access_token_if_needed!

  #     res = client.fetch_followed_users_by(user_id: target_id, next_token: next_token)
  #     followed_users = res["data"]
  #     result.data += res["data"]

  #     next_token = res.dig("meta", "next_token")
  #     progress_rate = 0# next_token ? (followed_users.count/target_follower_count.to_f) * 100 : 100

  #     yield(Result.new(@twitter_search_condition, followed_users), progress_rate) if block_given?

  #     break unless next_token
  #   end

  #   result
  # end

  def client
    @client ||= TwitterApiClient.new(access_token: @access_token, refresh_token: @refresh_token)
  end

  def update_client_access_token_if_needed!
    if @fetched_access_token_at < Time.now.ago(1.hour)
      @client = client.refresh_access_token!
      @fetched_access_token_at = Time.now

      user.update(
        twitter_access_token: @client.access_token,
        twitter_refresh_token: @client.refresh_token,
        fetched_access_token_at: @fetched_access_token_at
      )
    end
  end
end
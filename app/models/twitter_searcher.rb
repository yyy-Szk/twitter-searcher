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
    @fetched_access_token_at = @user.fetched_access_token_at
    @access_token = @user.twitter_access_token
    @refresh_token = @user.twitter_refresh_token
    update_client_access_token_if_needed!
  end

  def search(&block)
    raise NotImplementedError
  end

  private

  def client
    @client ||= TwitterApiClient.new(access_token: @access_token, refresh_token: @refresh_token)
  end

  def update_client_access_token_if_needed!
    if @fetched_access_token_at < Time.zone.now.ago(1.hour)
      @client = client.refresh_access_token!
      @fetched_access_token_at = Time.zone.now

      user.update(
        twitter_access_token: @client.access_token,
        twitter_refresh_token: @client.refresh_token,
        fetched_access_token_at: @fetched_access_token_at
      )
    end
  end
end
# frozen_string_literal: true

require "faraday"
require "json"
require_relative "twitter_api_client/error"

class TwitterApiClient
  API_ENDPOINT = "https://api.twitter.com"
  USERS_FIELDS = "public_metrics,id,username,description,name"
  TWEET_FIELDS = "public_metrics"
  # 設定可能な項目
  # created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld

  attr_reader :access_token, :debug_mode

  def initialize(access_token:, debug_mode: false)
    @access_token = access_token
    @debug_mode = debug_mode
  end

  def fetch_followed_users_by(user_id:, next_token: nil)
    path = "/2/users/#{user_id}/followers"
    params = {
      max_results: 1000,
      "user.fields": USERS_FIELDS,
      pagination_token: next_token
    }.compact
    response = connection_get(path, params)
    # 15リクエスト/15min
    sleep(60)

    parse(response)
  end

  # TODO: とりあえず、現状は使わない
  def fetch_following_users_by(user_id:)
    path = "/2/users/#{user_id}/following"
    params = {
      max_results: 1000,
      "user.fields": USERS_FIELDS
    }
    response = connection_get(path, params)

    parse(response)
  end


  # Structを必ず返すようにする
  # originalData
  # users default: [], idだけは絶対取れるようにするとか
  # tweets default: [], idだけは絶対取れるようにするとか
  # こいつについては、URLからユーザーidを取り出すのに使用する
  def fetch_user_by(username)
    username = retrieve_username(username)

    path = "/2/users/by/username/#{username}"
    params = {
      "user.fields": USERS_FIELDS
    }
    response = connection_get(path, params)

    parse(response)
  end

  def fetch_tweets_by(user_id:, next_token: nil)
    iso8601_format = "%Y-%m-%dT%H:%M:%SZ"

    path = "/2/users/#{user_id}/tweets"
    params = {
      start_time: Time.now.ago(1.month).strftime(iso8601_format),
      max_results: 100,
      exclude: "retweets,replies",
      "tweet.fields": TWEET_FIELDS,
      pagination_token: next_token
    }.compact
    response = connection_get(path, params)

    # 900リクエスト/15min。
    # sleep(1)
    parse(response)
  end

  def fetch_liking_users_by(tweet_id:, next_token: nil)
    path = "/2/tweets/#{tweet_id}/liking_users"
    params = {
      pagination_token: next_token,
      "user.fields": USERS_FIELDS
    }.compact
    response = connection_get(path, params)

    # 75リクエスト/15min
    sleep(12)
    parse(response)
  end

  private

  # @param [String] path
  # @param [Hash] params
  # @param [Hash] headers
  def connection_get(path, params = {}, headers = {})
    connection.get(path, params, headers)
  end

  # @param [String] path
  # @param [Hash] body
  # @param [Hash] headers
  def connection_post(path, params = {}, headers = {})
    connection.post(path, params, headers)
  end

  def parse(response)
    json = JSON.parse(response.body)

    case response.status
    when 200
      json
    when 429
      reset_at = Time.at(response.headers["x-rate-limit-reset"].to_i)
      message = json.map { "#{_1}: #{_2}" }.join(",\s")
      raise TooManyRequestError.new(message, reset_at: reset_at)
    else
      raise ResponseError json.map { "#{_1}: #{_2}" }.join(",\s")
    end
  end

  def authorization
    "Bearer #{access_token}"
  end

  def connection
    Faraday.new(API_ENDPOINT) do |builder|
      builder.headers[:Authorization] = authorization
      builder.request :url_encoded
      builder.response :logger if debug_mode
      builder.adapter Faraday.default_adapter
    end
  end

  def retrieve_username(username)
    username.sub("https://twitter.com/", "").sub(/(\?.*)?$/, "")
  end
end
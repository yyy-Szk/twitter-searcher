# frozen_string_literal: true

require "faraday"
require "json"
require_relative "twitter_api_client/error"

class TwitterApiClient
  API_ENDPOINT = "https://api.twitter.com"
  USERS_FIELDS = "public_metrics,id,username,description,name,protected"
  # attachments.poll_ids,attachments.media_keys,author_id,entities.mentions.username,geo.place_id,in_reply_to_user_id,referenced_tweets.id,referenced_tweets.id.author_id
  EXPANSION_FIELDS = "author_id"
  TWEET_FIELDS = "public_metrics,created_at"
  # 設定可能な項目
  # created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld

  class << self
    def access_token_expired?(access_token_fetch_date)
      access_token_fetch_date > Time.zone.now.ago(1.hour)
    end
  end

  attr_reader :access_token, :refresh_token, :debug_mode

  def initialize(access_token:, refresh_token: nil, debug_mode: false)
    @access_token = access_token
    @refresh_token = refresh_token
    @debug_mode = debug_mode
    twitter_credentials = Rails.application.credentials.twitter
    @client_id = twitter_credentials.dig(:oauth, :client_id)
    @client_secret = twitter_credentials.dig(:oauth, :client_secret)
  end

  def refresh_access_token!
    path = "/2/oauth2/token"
    params = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      # client_id: "LXVTR1NCV01ORXlDeF9HWnZUUU06MTpjaQ" # TODO: クライアントid
    }
    conn = Faraday.new(url: "https://api.twitter.com", params: params) do |builder|
      builder.headers["Content-Type"] = "application/x-www-form-urlencoded"
      builder.request :authorization, :basic, @client_id, @client_secret
      builder.adapter Faraday.default_adapter
    end
    res = conn.post("/2/oauth2/token")

    parsed_res = parse(res)
    @access_token = parsed_res["access_token"]
    @refresh_token = parsed_res["refresh_token"]

    self
  end

  def fetch_users_me
    path = "/2/users/me"
    params = {
      "user.fields": USERS_FIELDS
    }
    response = connection_get(path, params)

    parse(response)
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

  def fetch_following_users_by(user_id:, next_token: nil)
    path = "/2/users/#{user_id}/following"
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

  def fetch_user_by_id(user_id)
    path = "/2/users/#{user_id}"
    params = {
      "user.fields": USERS_FIELDS
    }
    response = connection_get(path, params)
    sleep(1)

    parse(response)
  end

  def fetch_tweets_by(user_id:, limit:, next_token: nil)
    iso8601_format = "%Y-%m-%dT%H:%M:%SZ"

    path = "/2/users/#{user_id}/tweets"
    params = {
      start_time: Time.zone.now.ago(limit).strftime(iso8601_format),
      max_results: 100,
      exclude: "retweets,replies",
      "tweet.fields": TWEET_FIELDS,
      pagination_token: next_token
    }.compact
    response = connection_get(path, params)

    # 900リクエスト/15min。
    sleep(1)
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

  def fetch_liking_tweets_by(user_id:, next_token: nil)
    path = "/2/users/#{user_id}/liked_tweets"
    params = {
      max_results: 100,
      pagination_token: next_token,
      "expansions": EXPANSION_FIELDS,
      "tweet.fields": TWEET_FIELDS,
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
    when 401
      message = "認証の有効期限が切れているので、再度認証してください"
      raise TwitterApiClient::UnAuthorizedError.new(message)
    when 429
      reset_at = Time.at(response.headers["x-rate-limit-reset"].to_i)
      message = json.map { "#{_1}: #{_2}" }.join(",\s")
      raise TooManyRequestError.new(message, reset_at: reset_at)
    else
      raise json.map { "#{_1}: #{_2}" }.join(",\s")
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
    username.sub("https://twitter.com/", "").sub(/(\?.*)?$/, "").strip
  end
end
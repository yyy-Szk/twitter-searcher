# frozen_string_literal: true

require "faraday"
require "json"

class TwitterApiClient
  # include ActiveModel::Model
  # include ActiveModel::Attributes
  API_ENDPOINT = "https://api.twitter.com"
  USERS_FIELDS = "public_metrics,id,username,description,name"
  # created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld

  class Error < StandardError; end
  class ResponseError < Error; end

  attr_reader :access_token, :debug_mode

  def initialize(access_token: nil, debug_mode: true)
    @access_token = access_token
    @debug_mode = debug_mode
  end

  # TODO: とりあえず、現状は使わない
  def fetch_followed_users_by(user_id:, next_token: nil)
    path = "/2/users/#{user_id}/followers"
    params = {
      max_results: 1000,
      "user.fields": USERS_FIELDS,
      pagination_token: next_token
    }.compact
    response = connection_get(path, params)

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
  def fetch_user_by(user_name:)
    path = "/2/users/by/username/#{user_name}"
    response = connection_get(path)

    parse(response)
  end

  def fetch_tweets_by(user_id:, next_token: nil)
    iso8601_format = "%Y-%m-%dT%H:%M:%SZ"

    path = "/2/users/#{user_id}/tweets"
    params = {
      start_time: Time.now.ago(1.month).strftime(iso8601_format),
      max_results: 10, # いいねのやつが15分で75リクエストまでなので、一旦75ツイートを最大にする
      exclude: "retweets,replies",
      pagination_token: next_token
    }.compact
    response = connection_get(path, params)

    parse(response)
  end

  # とりあえず、いいねした人を100人ずつ取ることにする = next-tokenは使用しない。いいロジックが浮かんだら使う
  def fetch_liking_users_by(tweet_id:, next_token: nil)
    path = "/2/tweets/#{tweet_id}/liking_users"
    params = {
      pagination_token: next_token,
      "user.fields": USERS_FIELDS
    }.compact
    response = connection_get(path, params)

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
    JSON.parse(response.body)
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
end
class Oauth::TwitterController < ApplicationController
  def new
    twitter_credentials = Rails.application.credentials.twitter
    parameters = {
      client_id: "LXVTR1NCV01ORXlDeF9HWnZUUU06MTpjaQ",
      grant_type: "authorization_code",
      code: params["code"],
      redirect_uri: "http://127.0.0.1:3000/auth/twitter/callback",
      code_verifier: "abc"
    }

    conn = Faraday.new(url: "https://api.twitter.com", params: parameters) do |builder|
      builder.request :authorization, :basic, twitter_credentials.dig(:oauth, :client_id), twitter_credentials.dig(:oauth, :client_secret)
      builder.adapter Faraday.default_adapter
    end
    res = JSON.parse conn.post("/2/oauth2/token").body

    current_user.update(
      twitter_access_token: res["access_token"],
      twitter_refresh_token: res["refresh_token"],
      fetched_access_token_at: Time.now
    )

    redirect_to root_path
  end

  def create

  end
end

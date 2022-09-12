class HomeController < ApplicationController
  before_action :validate, only: :search_customers

  def index
    @results = []
  end

  # TODO: 設計に迷ったので、一時的に追加。後ほど別のコントローラーに切り出したい
  def search_customers
    @results = twitter_searcher.search_users(params[:conditions])
    render "home/index"
  end

  private

  def twitter_searcher
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]
    TwitterSearcher.new(access_token: access_token)
  end

  def validate
  end
end

class HomeController < ApplicationController
  before_action :validate, only: :search_customers

  def index
    @results = []
  end

  # TODO: 設計に迷ったので、一時的に追加。後ほど別のコントローラーに切り出したい
  def search_customers
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]
    twitter_searcher = TwitterSearcher.new(access_token: access_token)

    params[:conditions].each do |index, value|
      p index, value["search_type"], value["content"]
    end

    @results = []

    render "home/index"
  end

  def validate
  end
end

class HomeController < ApplicationController
  before_action :validate, only: :search_customers

  def index
    @results = []
  end

  # TODO: 設計に迷ったので、一時的に追加。後ほど別のコントローラーに切り出したい
  # search_controller#create?
  def search_customers
    # redisのdockerレイヤ追加。
    #  Tweet.new(tweet_id, liking_users_json)
    # todo: user_id追加したい
    result = TwitterSearchResult.new
    if result.save
      SearchTwitterUserJob.perform_later(result, search_condition_params, narrow_down_condition_params)

      redirect_to action: "result", id: result.id
    else
      redirect_to action: "index"
    end
  end

  def result
    result = TwitterSearchResult.find(params[:id])
    @results = result.payload
    @progress_rate = result.progress_rate

    render "home/index"
  end

  private

  def search_condition_params
    params[:conditions].permit!
    # params.require(:conditions).permit(:)
  end

  def narrow_down_condition_params
    params[:narrow_down_conditions].permit!
  end

  def validate
  end
end

class HomeController < ApplicationController
  before_action :set_empty_result, only: [:index, :search_customers]
  before_action :validate, only: :search_customers

  def index
  end

  # TODO: 設計に迷ったので、一時的に追加。後ほど別のコントローラーに切り出したい
  # search_controller#create?
  def search_customers
    # redisのdockerレイヤ追加。
    #  Tweet.new(tweet_id, liking_users_json)
    # todo: user_id追加したい
    result = TwitterSearchResult.new
    if result.save
      search_conditions = search_condition_params.delete_if { _1["content"].empty? }
      narrow_down_conditions = narrow_down_condition_params.delete_if { _1["content"].empty? }
      SearchTwitterUserJob.perform_later(result, search_conditions, narrow_down_conditions)

      redirect_to action: "result", id: result.id
    else
      redirect_to action: "index"
    end
  end

  def result
    result = TwitterSearchResult.find(params[:id])
    @results = result.payload
    @progress_rate = result.progress_rate

    render "home/result"
  end

  private

  def search_condition_params
    params[:conditions].map do
      _1.permit(:content, :search_type)
    end
    # params.require(:conditions).permit(:)
  end

  def narrow_down_condition_params
    params[:narrow_down_conditions].map do
      _1.permit(:content, :search_type)
    end
  end

  def set_empty_result
    @results = []
  end

  def validate
    if search_condition_params.dig(0, "content").empty?
      p "=========="
      p search_condition_params
      p "=========="
      flash[:alert] = "検索対象のユーザーは、最低一つは入力してください。"
      render action: "index" and return
    end
  end
end

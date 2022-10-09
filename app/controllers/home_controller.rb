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
    search_conditions = search_condition_params.delete_if { _1["content"].empty? }
    narrow_down_conditions = narrow_down_condition_params.delete_if { _1["content"].empty? }

    result = TwitterSearchResult.new
    search_conditions.each do
      result.twitter_search_conditions.new(
        condition_type: :main,
        content: _1["content"],
        # TODO: to_iは一時的なものとして、もっといい対応方法がないか考える
        search_type: _1["search_type"].to_i
      )
    end

    narrow_down_conditions.each do
      result.twitter_search_conditions.new(
        condition_type: :narrowing,
        content: _1["content"],
        # TODO: to_iは一時的なものとして、もっといい対応方法がないか考える
        search_type: _1["search_type"].to_i
      )
    end
    
    if result.save
      SearchTwitterUserJob.perform_later(result)

      redirect_to action: "result", id: result.id
    else
      redirect_to action: "index"
    end
  end

  def result
    @result = TwitterSearchResult.find(params[:id])
    @results = @result.payload
    @main_conditions = @result.twitter_search_conditions.condition_type_main
    @narrowing_conditions = @result.twitter_search_conditions.condition_type_narrowing

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
    if search_condition_params.all? { _1["content"].empty? }
      p "=========="
      p search_condition_params
      p "=========="
      flash[:alert] = "検索対象のユーザーは、最低一つは入力してください。"
      render action: "index" and return
    end
  end
end

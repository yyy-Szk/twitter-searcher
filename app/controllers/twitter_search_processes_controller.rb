class TwitterSearchProcessesController < ApplicationController
  before_action :validate, only: :create

  def new
    @is_authenticated = !(params[:need_auth] == "true")
  end

  def show
    @process = TwitterSearchProcess.find(params[:id])
    @results = TwitterSearchResult.where(twitter_search_process: @process).page(params[:page]).per(3)
    @main_conditions = @process.twitter_search_conditions.condition_type_main
    @narrowing_conditions = @process.twitter_search_conditions.condition_type_narrowing
  end

  def create
    # redisのdockerレイヤ追加。
    #  Tweet.new(tweet_id, liking_users_json)
    # todo: user_id追加したい
    search_conditions = search_condition_params.delete_if { _1["content"].empty? }
    narrow_down_conditions = narrow_down_condition_params.delete_if { _1["content"].empty? }

    process = TwitterSearchProcess.new(user: current_user, status: :progressing)
    search_conditions.each do
      process.twitter_search_conditions.new(
        condition_type: :main,
        content: _1["content"],
        # TODO: to_iは一時的なものとして、もっといい対応方法がないか考える
        search_type: _1["search_type"].to_i
      )
    end

    narrow_down_conditions.each do
      process.twitter_search_conditions.new(
        condition_type: :narrowing,
        content: _1["content"],
        # TODO: to_iは一時的なものとして、もっといい対応方法がないか考える
        search_type: _1["search_type"].to_i
      )
    end

    if params["remove_following_user"] == "true"
      process.twitter_search_conditions.new(
        condition_type: :narrowing,
        content: "自分",
        search_type: :not_following_current_user
      )
    end

    if process.save
      SearchTwitterUserJob.perform_later(process)

      redirect_to action: "show", id: process.id
    else
      redirect_to action: "new"
    end
  end

  def update
    process = TwitterSearchProcess.find(params[:id])
    process.update(status: :will_finish)

    redirect_to twitter_search_process_url(process.id)
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

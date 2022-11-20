class TwitterSearchProcessesController < ApplicationController
  before_action :validate, only: :create
  before_action :require_login

  def new
    @is_authenticated = !(params[:need_auth] == "true")
  end

  def show
    @process = TwitterSearchProcess.find(params[:id])
    # 一つの結果には、最大で500まで入れられるようにする。
    @results = TwitterSearchResult.where(twitter_search_process: @process).page(params[:page]).per(3)
    @main_conditions = @process.twitter_search_conditions.condition_type_main
    @narrowing_conditions = @process.twitter_search_conditions.condition_type_narrowing
  end

  def create
    # 文字列で統一
    options = { "remove_following_user" => params["remove_following_user"] }
    process = TwitterSearchProcess.create_with_conditions(current_user, search_condition_params, narrow_condition_params, options)
    if process.persisted?
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
    params[:search_conditions].map do
      _1.permit(:content, :search_type, :num_of_days)
    end
  end

  def narrow_condition_params
    params[:narrow_conditions].map do
      _1.permit(:content, :search_type, :num_of_days)
    end
  end

  def validate
    if search_condition_params.all? { _1["content"].empty? }
      flash[:alert] = "検索対象のユーザーは、最低一つは入力してください。"
      @is_authenticated = "true"
      render action: :new and return
    end

    # TODO バリデーション
    # if search_condition_params.select { _1["search_type"].empty? }
    #   flash[:alert] = "検索対象のユーザーは、最低一つは入力してください。"
    #   render action: :new and return
    # end
  end

  def require_login
    redirect_to login_url unless logged_in?
  end
end

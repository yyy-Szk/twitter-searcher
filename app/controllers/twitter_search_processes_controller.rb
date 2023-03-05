class TwitterSearchProcessesController < ApplicationController
  before_action :validate, only: :create
  before_action :require_login

  def new
    @process_type = params[:process_type]
    @auth_url = auth_url
  end

  def show
    @twitter_search_process_id = params[:id]
    @auth_url = auth_url
  end

  def json_data
    process = TwitterSearchProcess.find(params[:id])
    total_count = process.twitter_search_results.sum { _1.data.count }

    render json: {
      process: process,
      total_count: total_count,
      results: process.twitter_search_results.page(params[:page]).per(1).flat_map(&:data),
      main_conditions: process.twitter_search_conditions.condition_type_main.map {
        JSON.parse(_1.to_json).merge(type: _1.type)
      },
      narrowing_conditions: process.twitter_search_conditions.condition_type_narrowing.map {
        JSON.parse(_1.to_json).merge(type: _1.type)
      }
    }
  end

  def create
    # 文字列で統一
    options = { "remove_following_user" => params["remove_following_user"] }

    process = TwitterSearchProcess.create_with_conditions(current_user, params[:process_type], search_condition_params, narrow_condition_params, options)
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

  def auth_url
    client_id = Rails.application.credentials.twitter.dig(:oauth, :client_id)
    url = ENV["TWITTER_CALLBACK"] || Rails.application.credentials.twitter.dig(:oauth, :callback_url)
    redirect_uri = CGI.escape(url)
    scopes = "tweet.read%20users.read%20like.read%20follows.read%20follows.write%20offline.access"

    "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scopes}&state=abc&code_challenge=abc&code_challenge_method=plain"
  end

  def search_condition_params
    params[:search_conditions].map { _1.permit(:content, :search_type, :num_of_days) } || []
  end

  def narrow_condition_params
    params[:narrow_conditions]&.map { _1.permit(:content, :search_type, :num_of_days) } || []
  end

  def validate
    if search_condition_params.all? { _1["content"].strip.empty? }
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
end

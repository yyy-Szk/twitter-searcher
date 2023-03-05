class SessionsController < ApplicationController
  before_action :redirect_searching_page, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(uid: params[:uid])
    if user && user.authenticate(params[:password])
      login(user)
      flash[:notice] = 'ログインしました'
      redirect_to controller: "twitter_search_processes", action: "new"# , need_auth: "true"
    else
      flash[:notice] = 'ログインに失敗しました。'

      redirect_to login_path
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  private

  def redirect_searching_page
    redirect_to new_twitter_search_process_url if logged_in?
  end
end

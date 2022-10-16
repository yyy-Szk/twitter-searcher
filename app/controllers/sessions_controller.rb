class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(uid: params[:uid])
    if user && user.authenticate(params[:password])
      user.update(twitter_access_token: nil, twitter_refresh_token: nil)
      login(user)
      flash[:notice] = 'ログインしました'

      redirect_to root_path
    else
      flash[:notice] = 'ログインに失敗しました。'

      redirect_to login_path
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end

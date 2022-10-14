class Sessions::TwitterController < ApplicationController
  def create
    user = User.find_or_create_by_oauth(omniauth_params)
    if user
      log_in(user)
      flash[:notice] = 'ログインしました'
    else
      flash[:notice] = '失敗しました'
    end

    redirect_to root_path
  end

  def destroy

  end

  private

  def omniauth_params
    request.env['omniauth.auth']
  end

end

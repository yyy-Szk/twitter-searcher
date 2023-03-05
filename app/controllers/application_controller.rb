class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def require_login
    redirect_to login_url unless logged_in?
  end

  def redirect_searching_page
    redirect_to new_twitter_search_process_url if logged_in?
  end
end

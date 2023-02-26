class HomeController < ApplicationController
  before_action :require_login, only: :index
  before_action :redirect_searching_page, only: :index

  def index
  end
end

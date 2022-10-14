class User < ApplicationRecord
  has_many :twitter_search_process, dependent: :destroy

  def self.find_or_create_by_oauth(omniauth_params)
    user = find_or_initialize_by(twitter_user_id: omniauth_params[:uid]) do |user|
      user.twitter_user_id = omniauth_params[:uid]
      user.twitter_username = omniauth_params[:info][:nickname]
    end
    p omniauth_params[:credentials]
    user.twitter_access_token = omniauth_params[:credentials][:token]
    user.save
    # "1068118862896422913-HBFBtuYXRjqzueIt6pYVCQv3AAEw1b:4ZajSwN3Z3tcumqxtPoyO90at6mXnL1Y2jKhybl9tqA3T"
    user
  end
end

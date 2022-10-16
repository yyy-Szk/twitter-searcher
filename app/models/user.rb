class User < ApplicationRecord
  has_many :twitter_search_process, dependent: :destroy
  validates :uid, uniqueness: true

  has_secure_password

  

  def self.find_or_create_by_oauth(omniauth_params)
    # user = find_or_initialize_by(twitter_user_id: omniauth_params[:uid]) do |user|
    #   user.twitter_user_id = omniauth_params[:uid]
    #   user.twitter_username = omniauth_params[:info][:nickname]
    # end
    # p omniauth_params[:credentials]
    # user.twitter_access_token = omniauth_params[:credentials][:token]
    # user.save
    # # "1068118862896422913-HBFBtuYXRjqzueIt6pYVCQv3AAEw1b:4ZajSwN3Z3tcumqxtPoyO90at6mXnL1Y2jKhybl9tqA3T"
    # user
    
  end

  def refresh_access_token_if_needed!
    # TwitterApiClient.access_token_expired?(fetched_access_token_at)
  end

  def has_active_process?
    active_process.present?
  end

  def active_process
    twitter_search_process.where("progress_rate != ?", 100)
  end
end

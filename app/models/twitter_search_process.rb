class TwitterSearchProcess < ApplicationRecord
  belongs_to :user
  has_many :twitter_search_conditions, dependent: :destroy
  has_many :twitter_search_results, dependent: :destroy
end

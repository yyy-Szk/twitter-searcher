class TwitterSearchProcess < ApplicationRecord
  belongs_to :user
  has_many :twitter_search_conditions
  has_many :twitter_search_results
end

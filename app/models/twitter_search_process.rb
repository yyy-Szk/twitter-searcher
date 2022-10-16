class TwitterSearchProcess < ApplicationRecord
  belongs_to :user
  has_many :twitter_search_conditions, dependent: :destroy
  has_many :twitter_search_results, dependent: :destroy

  enum status: { progressing: 0, will_finish: 1, finished: 2 }, _prefix: true
end

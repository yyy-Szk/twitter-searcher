class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(condition)
    # search_result = twitter_searcher.search_users(condition)
    p condition
    # Do something later
  end
end

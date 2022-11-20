class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(twitter_search_process)
    twitter_search_process.execute!
  end
end

class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(result, conditions)
    # conditions.each do
    twitter_searcher(result).search_users!(conditions)
    # result.update()
    # end
  end

  private

  def twitter_searcher(result)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]
    TwitterSearcher.new(result, access_token)
  end
end

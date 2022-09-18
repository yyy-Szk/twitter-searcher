class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(result, search_conditions, narrow_down_conditions)
    # narrow_down_conditions.map do
    #   TwitterSearcher.new(search_type, condition)
    # end
    # conditions.each do
    twitter_searcher(result).search_liking_users_case(search_conditions, narrow_down_conditions)
    # twitter_searcher(result).search_users!(conditions)
    # result.update!(progress_rate: 0, payload: {})
    # end
  end

  private

  def twitter_searcher(result)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]
    TwitterSearcher.new(result, access_token)
  end
end

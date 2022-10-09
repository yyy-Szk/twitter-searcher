class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  # @param [Array<Hash>] search_conditions
  # => [ {"content"=>"aa", "search_type"=>"0"}, ... ]
  # @param [Array<Hash>] narrow_down_conditions
  # => [ {"content"=>"bbb", "search_type"=>"0"}, ... ]
  def perform(twitter_search_result)
    search_conditions = twitter_search_result.twitter_search_conditions.condition_type_main
    narrow_down_conditions = twitter_search_result.twitter_search_conditions.condition_type_narrowing

    search_conditions.size + narrow_down_conditions.size

    p "絞り込み条件取得開始"
    results = narrow_down_conditions.map do |condition|
      searcher(condition).search_users do |data, progress_rate|
        p "絞り込み条件取得中"
        
        # 進捗
        # twitter_search_result.update progrss_rate: progrss_rate
      end
    end
    p "絞り込み条件取得終了"
    p "ユーザー取得開始"

    # 本番ユーザー取得
    search_conditions.each do |search_condition|
      searcher(search_condition).search_users do |result, progress_rate|
        results.each { result.calc(_1) }
        p "ユーザー取得取得中"

        payload = twitter_search_result.payload | result.data

        twitter_search_result.update payload: twitter_search_result.payload | payload #, progress_rate
      end
    end
    p "ユーザー取得終了"

  rescue => e
    twitter_search_result.update error_class: e.class, error_message: e.message
  ensure
    twitter_search_result.update progress_rate: 100
  end

  private

  def searcher(twitter_search_condition)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]

    TwitterSearcher.new(twitter_search_condition, access_token)
  end
end

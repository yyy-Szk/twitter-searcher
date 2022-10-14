class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  # @param [Array<Hash>] search_conditions
  # => [ {"content"=>"aa", "search_type"=>"0"}, ... ]
  # @param [Array<Hash>] narrow_down_conditions
  # => [ {"content"=>"bbb", "search_type"=>"0"}, ... ]
  def perform(twitter_search_process)
    search_conditions = twitter_search_process.twitter_search_conditions.condition_type_main
    narrow_down_conditions = twitter_search_process.twitter_search_conditions.condition_type_narrowing
    current_user = twitter_search_process.user
    # access_token = current_user.twitter_access_token
    # refresh_token = current_user.twitter_refresh_token

    p "絞り込み条件取得開始"
    results = narrow_down_conditions.map do |condition|
      searcher(condition, current_user).search_users do |data, progress_rate|
        p "絞り込み条件取得中"
        return if twitter_search_process.reload.status_will_finish?

        # 進捗
        # twitter_search_process.update progrss_rate: progrss_rate
      end
    end

    p "絞り込み条件取得終了"
    p "ユーザー取得開始"

    # 本番ユーザー取得
    search_conditions.inject([]) do |feched_users, search_condition|
      p "ユーザー取得1"
      search_result = searcher(search_condition, current_user).search_users do |result, progress_rate|
        p "ユーザー取得2"
        results.each { result.calc(_1) }
        p "ユーザー取得中"

        data = result.data.select { feched_users.pluck("username").exclude?(_1["username"]) }
        p data
        if data.present?
          TwitterSearchResult.create(twitter_search_process: twitter_search_process, data: data)
          return if twitter_search_process.reload.status_will_finish?

          # payload = twitter_search_process.payload | result.data
          # twitter_search_process.update payload: twitter_search_process.payload | payload #, progress_rate
        end
      end

      feched_users | search_result.data
    end
    p "ユーザー取得終了"

  rescue => e
    error_class = "#{e.class} / #{e.backtrace}"
    twitter_search_process.update error_class: error_class, error_message: e.message
  ensure
    twitter_search_process.update progress_rate: 100, status: :finished
  end

  private

  def searcher(twitter_search_condition, user)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    # access_token = Rails.application.credentials.twitter[:bearer_token]

    TwitterSearcher.new(twitter_search_condition, user)
  end
end

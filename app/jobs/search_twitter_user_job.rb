class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(result, search_conditions, narrow_down_conditions)
    p "絞り込み条件取得開始"
    users_for_narrow_down = []
    # メソッド切り出し
    narrow_down_conditions.each.with_index(1) do |(_, condition), i|
      users = searcher(condition[:search_type], condition[:content]).search_users
      if i == 1
        users_for_narrow_down += users
      else
        users_for_narrow_down &= users
      end
    end
    p "絞り込み条件取得終了", "件数: #{users_for_narrow_down.size}"

    # メソッド切り出し
    search_conditions.each do |_, condition|
      users = searcher(condition[:search_type], condition[:content]).search_users do |progress_rate, users|
        result.update(progress_rate: progress_rate, payload: users & users_for_narrow_down)
      end
    end
  end

  private

  def searcher(search_type, search_condition)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]

    TwitterSearcher.new(search_type, search_condition, access_token)
  end
end

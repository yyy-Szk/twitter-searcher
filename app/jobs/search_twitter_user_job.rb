class SearchTwitterUserJob < ApplicationJob
  queue_as :search_twitter_user

  def perform(result, search_conditions, narrow_down_conditions)
    p "絞り込み条件取得開始"
    users_for_narrow_down = []
    # メソッド切り出し
    narrow_down_conditions.each.with_index(1) do |(_, condition), i|
      next if condition[:content].empty?
      users = searcher(condition[:search_type], condition[:content]).search_users
      if i == 1
        users_for_narrow_down += users
      else
        users_for_narrow_down &= users
      end
    end
    p "絞り込み条件取得終了", "件数: #{users_for_narrow_down.size}"

    # メソッド切り出し
    p "ユーザー取得開始"
    search_conditions.each do |_, condition|
      next if condition[:content].empty?

      users = searcher(condition[:search_type], condition[:content]).search_users do |progress_rate, users|
        payload = users_for_narrow_down.present? ? users & users_for_narrow_down : users
       
        result.update(progress_rate: progress_rate, payload: payload)
      end
    end
    p "ユーザー取得終了"
  end

  private

  def searcher(search_type, search_condition)
    # TODO: 一時的な対応。後ほどログインさせて、ログインしているユーザーの情報から持ってくる
    access_token = Rails.application.credentials.twitter[:bearer_token]

    TwitterSearcher.new(search_type, search_condition, access_token)
  end
end

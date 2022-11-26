class TwitterSearchProcess < ApplicationRecord
  belongs_to :user
  has_many :twitter_search_conditions, dependent: :destroy
  has_many :twitter_search_results, dependent: :destroy

  enum status: { progressing: 0, will_finish: 1, finished: 2 }, _prefix: true

  class << self
    def create_with_conditions(user, search_condition_params, narrow_condition_params, options = {})
      search_condition_params = search_condition_params.delete_if { _1["content"].strip.empty? }
      narrow_condition_params = narrow_condition_params.delete_if { _1["content"].strip.empty? }

      process = self.new(user: user, status: :progressing)
      search_condition_params.each do
        process.twitter_search_conditions.new(
          condition_type: :main,
          content: _1["content"].strip,
          type: _1["search_type"],
          num_of_days: _1["num_of_days"],
        )
      end

      narrow_condition_params.each do
        process.twitter_search_conditions.new(
          condition_type: :narrowing,
          content: _1["content"].strip,
          type: _1["search_type"],
          num_of_days: _1["num_of_days"],
        )
      end

      if options["remove_following_user"] == "true"
        process.twitter_search_conditions.new(
          condition_type: :narrowing,
          content: "自分",
          type: "NotFollowingCurrentUser",
        )
      end
      process.save

      process
    end
  end

  def execute!
    message = ""

    p "絞り込み条件取得開始"
    # setup_narrow_conditions
    results = narrow_conditions.map do |condition|
      condition.search do |data, progress_rate|
        p "絞り込み条件取得中"
        if self.reload.status_will_finish?
          message = "処理がキャンセルされました"
          return
        end

        # 進捗
        # self.update progrss_rate: progrss_rate
      end
    end

    p "絞り込み条件取得終了"
    p "ユーザー取得開始"

    # 本番ユーザー取得
    search_conditions.inject([]) do |feched_users, search_condition|
      search_result = search_condition.search do |result, progress_rate|
        if self.reload.status_will_finish?
          message = "処理がキャンセルされました"
          return
        end

        if result.data.present?
          results.each { result.narrowing(_1) }
          p "ユーザー取得中"

          data = result.data.select { feched_users.pluck("username").exclude?(_1["username"]) }
          data = data.select { _1["protected"] == false }
          if data.present?
            if last_result = self.twitter_search_results.order(created_at: :desc).limit(1).first
              last_result_data = last_result.data
              if last_result_data.size < 100
                dadata = data.slice!(...(100 - last_result_data.size))
                last_result.update(data: last_result_data + dadata)
              end
            end

            # 一気にimportで入れたいけど、どうするか。
            data.each_slice(100) do |sliced_data|
              self.twitter_search_results.create(data: sliced_data)
            end
            # payload = twitter_search_process.payload | result.data
            # twitter_search_process.update payload: twitter_search_process.payload | payload #, progress_rate
          end
        end
      end

      feched_users | search_result.data
    end
    p "ユーザー取得終了"
  rescue TwitterApiClient::Error => e
    p "=========="
    Rails.logger.info e.backtrace
    p "=========="
    Rails.logger.info e.message
    message = e.message
    p "=========="

    self.update error_class: e.class
  rescue => e
    p "=========="
    Rails.logger.info e.backtrace
    p "=========="
    Rails.logger.info e.message
    message = "予期せぬエラーが発生しました。入力値をお確かめの上、再実行してください。"
    p "=========="

    self.update error_class: e.class
  ensure
    self.update progress_rate: 100, status: :finished, error_message: message
  end

  def search_conditions
    twitter_search_conditions.condition_type_main
  end

  def narrow_conditions
    twitter_search_conditions.condition_type_narrowing
  end
end

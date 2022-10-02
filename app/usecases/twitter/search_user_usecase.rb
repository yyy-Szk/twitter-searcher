module Twitter
  class SearchUserUsecase
    # input: search_type, search_content, twitter_search_result
    class << self
      def run!(...)
        self.new(...).run!
      end
    end

    attr_reader :search_conditions, :narrow_down_conditions, :twitter_search_result

    def initialize(search_conditions, narrow_down_conditions, twitter_search_result)
      @search_conditions = search_conditions
      @narrow_down_conditions = narrow_down_conditions
      @twitter_search_result = twitter_search_result
    end

    def run!
      # 絞り込み条件取得
      results = narrow_down_conditions.map do |condition|
        # search_usersの戻りが帰ってくる(#<ResultData >)
        searcher.search_users(data: ResultData.new) do |data|
          # dataは、#<ResultData > 
          # 進捗
          result.update progrss_rate: progrss_rate
        end
      end

      # 本番ユーザー取得
      search_conditions.each do |search_condition|
        searcher.search_users(data: ResultData.new) do |data|
          kekka = data.narrow_down(results)
          test = result.data & kekka
          result.update payload: test, progress_rate
        end
      end
    end
  end
end

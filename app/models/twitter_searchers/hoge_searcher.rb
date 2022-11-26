# frozen_string_literal: true

module TwitterSearchers
  class HogeSearcher < TwitterSearcher
    def search
      Result.new(@twitter_search_condition)
    end
  end
end

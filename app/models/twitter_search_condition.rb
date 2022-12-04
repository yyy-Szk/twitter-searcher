# frozen_string_literal: true

class TwitterSearchCondition < ApplicationRecord
  belongs_to :twitter_search_process

  enum condition_type: { main: 0, narrowing: 1 }, _prefix: true

  delegate :user, to: :twitter_search_process
  delegate :search, to: :searcher, allow_nil: true

  class << self
    def main_search_types
    end

    def narrowing_search_types
    end
  end

  def narrowing
    raise NotImplementedError
  end

  def searcher
    raise NotImplementedError
  end
end

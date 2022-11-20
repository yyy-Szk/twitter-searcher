# frozen_string_literal: true

class TwitterSearchCondition < ApplicationRecord
  belongs_to :twitter_search_process

  enum condition_type: { main: 0, narrowing: 1 }, _prefix: true
  # search_types = %i[
  #   LikedTweetUser FollowingUser
  # ].freeze

  # narrowing_types = %i[
  #   LikedTweetUser NotLikedTweetuser FollowingUser NotFollowingUser NotFollowingCurrentUser
  # ]
  enum search_type: {
    liked_in_the_last_month: 0,
    liked_in_the_last_two_month: 1,
    liked_in_the_last_three_month: 2,
    not_liked_in_the_last_month: 3,
    not_liked_in_the_last_two_month: 4,
    not_liked_in_the_last_three_month: 5,
    following: 6,
    not_following: 7,
    not_following_current_user: 8, # 主に、自分がフォローしているユーザーを排除するのに使用する
  }, _prefix: true

  delegate :user, to: :twitter_search_process
  delegate :search, to: :searcher

  class << self
    def main_search_types
      TwitterSearchCondition.search_types.dup.delete_if { |k,_| k.start_with?("not_") }
    end

    def narrowing_search_types
      TwitterSearchCondition.search_types.dup.delete_if { |k, _| k == "not_following_current_user" }
    end
  end

  def operator
    raise NotImplementedError
  end

  def searcher
    raise NotImplementedError
  end
end

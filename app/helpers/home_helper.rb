module HomeHelper
  def main_twitter_search_types
    {
      "フォローしているユーザー": "FollowingUser",
      "いいねしたユーザー": "LikedTweetUser",
    }
  end

  def twitter_search_types_for_narrowing
    {
      "フォローしているユーザー": "FollowingUser",
      "フォローしていないユーザー": "NotFollowingUser",
      "いいねしたユーザー": "LikedTweetUser",
      "いいねしていないユーザー": "NotLikedTweetUser",
    }
  end
end

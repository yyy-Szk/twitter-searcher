module HomeHelper
  def main_twitter_search_types
    {
      "フォロワーであるユーザー": "FollowingUser",
      "ツイートをいいねしたユーザー": "LikedTweetUser",
      "フォローしているユーザー": "FollowedUser",
      "いいねしたユーザー": "LikingUser",
    }
  end

  def twitter_search_types_for_narrowing
    # followed user と following user の意味を入れ替えたい
    {
      "フォロワーであるユーザー": "FollowingUser",
      "フォロワーではないユーザー": "NotFollowingUser",
      "ツイートをいいねしたユーザー": "LikedTweetUser",
      "ツイートをいいねしていないユーザー": "NotLikedTweetUser",
      "文字をプロフィールに含むユーザー": "IncludedWordInProfileUser",
      "文字をプロフィールに含まないユーザー": "NotIncludedWordInProfileUser",
      "フォローしているユーザー": "FollowedUser",
      "いいねしたユーザー": "LikingUser",
    }
  end
end

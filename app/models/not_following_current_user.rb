class NotFollowingCurrentUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::FollowingCurrentUserSearcher.new(self)
  end

  def narrowing(data, other_data)
    other_usernames = other_data.pluck("username")

    data.reject { other_usernames.include?_1["username"] }
  end
end

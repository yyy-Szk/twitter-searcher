class FollowingUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::FollowingUserSearcher.new(self)
  end

  def narrowing(data, other_data)
    other_usernames = other_data.pluck("username")

    data.select { other_usernames.include?_1["username"] }
  end
end

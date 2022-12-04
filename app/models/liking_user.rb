class LikingUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::LikingUserSearcher.new(self)
  end

  def narrowing(data, other_data)
    other_usernames = other_data.pluck("username")

    data.select { other_usernames.include?_1["username"] }
  end
end

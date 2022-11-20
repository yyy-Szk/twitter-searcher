class FollowingUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::FollowingUserSearcher.new(self)
  end

  def operator
    "&"
  end
end

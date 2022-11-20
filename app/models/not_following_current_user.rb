class NotFollowingCurrentUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::FollowingCurrentUserSearcher.new(self)
  end

  def operator
    "-"
  end
end

class NotLikedTweetUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::LikedTweetUserSearcher.new(self)
  end

  def operator
    "-"
  end
end

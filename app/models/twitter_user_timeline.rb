class TwitterUserTimeline < TwitterSearchCondition
  def searcher
    TwitterSearchers::TimelineSearcher.new(self)
  end
end

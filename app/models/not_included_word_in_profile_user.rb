class NotIncludedWordInProfileUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::HogeSearcher.new(self)
  end

  def narrowing(data, _)
    data.reject { _1["description"].include?(content) }
  end
end

class IncludedWordInProfileUser < TwitterSearchCondition
  def searcher
    TwitterSearchers::HogeSearcher.new(self)
  end

  def narrowing(data, _)
    data.select { _1["description"].include?(content) }
  end
end

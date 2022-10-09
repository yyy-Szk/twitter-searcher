module HomeHelper
  def main_twitter_search_types
    TwitterSearchCondition.main_search_types.map {
      [TwitterSearchCondition.human_attribute_enum_value("search_type", _1), _2]
    }.to_h
  end

  def twitter_search_types_for_narrowing
    TwitterSearchCondition.narrowing_search_types.map {
      [TwitterSearchCondition.human_attribute_enum_value("search_type", _1), _2]
    }.to_h
  end
end

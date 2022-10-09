FactoryBot.define do
  factory :twitter_search_condition do
    twitter_search_result { create(:twitter_search_result) }
    condition_type { 0 }
    search_type { 0 }
    content { "https://twitter.com/yyy_szk" }
  end
end

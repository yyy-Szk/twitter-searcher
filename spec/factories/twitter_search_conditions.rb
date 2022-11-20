FactoryBot.define do
  factory :twitter_search_condition do
    twitter_search_process
    condition_type { 0 }
    type { nil }
    content { "https://twitter.com/yyy_szk" }
  end
end

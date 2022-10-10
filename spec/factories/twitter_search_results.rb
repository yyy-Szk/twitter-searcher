FactoryBot.define do
  factory :twitter_search_result do
    twitter_search_process
    data { [] }
  end
end

FactoryBot.define do
  factory :following_user do
    twitter_search_process
    condition_type { :main }
    type { "FollowingUser" }
    content { "https://twitter.com/yyy_szk" }
  end
end

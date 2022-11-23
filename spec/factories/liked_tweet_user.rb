FactoryBot.define do
  factory :liked_tweet_user do
    twitter_search_process
    condition_type { :main }
    type { "LikedTweetUser" }
    content { "https://twitter.com/Ito_J22" }
    num_of_days { 2 }
  end
end

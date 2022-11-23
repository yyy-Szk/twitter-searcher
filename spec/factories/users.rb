FactoryBot.define do
  factory :user do
    uid { "suzuki" }
    password_digest { "password" }
    twitter_user_id { "01" }
    twitter_username { "yyy-Szk" }
    twitter_access_token { Rails.application.credentials.twitter[:bearer_token] }
    twitter_refresh_token { "sample" }
    fetched_access_token_at { Time.zone.now }
  end
end

FactoryBot.define do
  factory :twitter_search_process do
    user
    progress_rate { 0 }
    error_class { nil }
    error_message { nil }
  end
end

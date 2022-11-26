FactoryBot.define do
  factory :included_word_in_profile_user do
    twitter_search_process
    condition_type { :main }
    type { "IncludedWordInProfileUser" }
    content { "プログラミングスクール" }
  end
end

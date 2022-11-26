FactoryBot.define do
  factory :not_included_word_in_profile_user do
    twitter_search_process
    condition_type { :main }
    type { "NotIncludedWordInProfileUser" }
    content { "プログラミングスクール" }
  end
end

require 'rails_helper'

RSpec.describe TwitterSearchProcess, type: :model do
  dir = "twitter_search_process"

  let(:user) { create(:user) }

  describe "" do
    let(:twitter_search_process) do
      process = create(:twitter_search_process, user: user)
      create(:following_user, twitter_search_process: process, condition_type: :main)

      process
    end

    before do
      allow_any_instance_of(TwitterApiClient).to(receive(:sleep))
    end

    example "", vcr: { cassette_name: "#{dir}/success_execute_by_following_user" } do
      twitter_search_process.execute!
    end
  end

  describe do
    let(:twitter_search_process) do
      process = create(:twitter_search_process, user: user)
      create(:liked_tweet_user, twitter_search_process: process, condition_type: :main)

      process
    end

    before do
      allow_any_instance_of(TwitterApiClient).to(receive(:sleep))
    end

    example "", vcr: { cassette_name: "#{dir}/success_execute_by_liked_tweet_user" } do
      twitter_search_process.execute!
    end
  end

  describe do
    let(:twitter_search_process) do
      process = create(:twitter_search_process, user: user)
      create(:following_user,
        condition_type: :main,
        twitter_search_process: process
      )
      create(:included_word_in_profile_user,
        condition_type: :narrowing,
        twitter_search_process: process
      )

      process
    end

    before do
      allow_any_instance_of(TwitterApiClient).to(receive(:sleep))
    end

    example "", vcr: { cassette_name: "#{dir}/success_execute_by_following_user" } do
      twitter_search_process.execute!
    end
  end
end

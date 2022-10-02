require 'rails_helper'

RSpec.describe SearchTwitterUserJob, type: :job do
  describe "#perform", vcr: { cassette_name: "success_fetching_followers" } do
    example do
      ActiveJob::Base.queue_adapter = :test #jobを起動するアダプターtest環境ではtestにしておく

      allow_any_instance_of(TwitterApiClient).to(receive(:sleep))
      result = create(:twitter_search_result)
      search_condition_params = [{ "search_type" => "1", "content" => "https://twitter.com/konzo_goriki" }]
      narrow_down_condition_params = [{ "search_type" => "3", "content" => "https://twitter.com/yyy_szk" }]

      expect {
        SearchTwitterUserJob.perform_now(result, search_condition_params, narrow_down_condition_params)
      }.to(
        change { result.reload.progress_rate }.to(100)
      )

    end
  end
end

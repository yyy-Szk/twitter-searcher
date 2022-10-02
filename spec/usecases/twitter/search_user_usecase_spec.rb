require "rails_helper"
RSpec.describe Twitter::SearchUserUsecase do
  # input: search_type, search_content, twitter_search_result
  describe ".run!" do
    let(:twitter_search_result) { create(:twitter_search_result) }

    example "渡した twitter_search_result の payload に ユーザ情報の配列が、progress_rateに 100 が入る" do
      expect {
        Twitter::SearchUserUsecase.run!("1", "https://twitter.com/konzo_goriki", twitter_search_result)
      }.to(
        change { twitter_search_result.reload.payload }.to([])
        .and change { twitter_search_result.reload.progress_rate }.to(100)
      )
    end
  end
end

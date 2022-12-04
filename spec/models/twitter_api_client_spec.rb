require 'rails_helper'

RSpec.describe TwitterApiClient, type: :model do
  dir = "twitter_api_client"

  let(:client) do
    client = TwitterApiClient.new(access_token: Rails.application.credentials.twitter[:bearer_token])
    allow(client).to(receive(:sleep))

    client
  end

  describe "#fetch_liking_tweets_by" do
    example "", vcr: { cassette_name: "#{dir}/success_fetch_liking_tweets_by" } do
      expect(client.fetch_liking_tweets_by(user_id: 793773135887634432)).to(
        include("data" => be_a(Array))
      )
    end
  end
end

require "rails_helper"

RSpec.describe TwitterSearcher do
  describe "#search_users" do
    context "フォロワー検索の場合" do
      example "", vcr: { cassette_name: "success_fetching_followers" } do
        token = Rails.application.credentials.twitter[:bearer_token]
        condition = create(:twitter_search_condition,
          condition_type: :main,
          search_type: :following,
          content: "https://twitter.com/konzo_goriki"
        )

        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r1 = searcher.search_users
        # expect(r).to(eq([]))

        condition = create(:twitter_search_condition,
          condition_type: :narrowing,
          search_type: :following,
          content: "https://twitter.com/yyy_szk"
        )
        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r2 = searcher.search_users

        expect(r1.calc(r2).pluck("username")).to(match_array(["tatoyeba", "aim2bpg", "programd_taiga", "fushifushi_y", "komagata"]))
      end

      example "", vcr: { cassette_name: "success_fetching_followers_2" } do
        token = Rails.application.credentials.twitter[:bearer_token]
        condition = create(:twitter_search_condition,
          condition_type: :main,
          search_type: :following,
          content: "https://twitter.com/yyy_szk"
        )

        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r1 = searcher.search_users

        condition = create(:twitter_search_condition,
          condition_type: :narrowing,
          search_type: :not_following,
          content: "https://twitter.com/yyy_szk"
        )
        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r2 = searcher.search_users
        r1.calc(r2)
        expect(r1.data.size).to(eq(0))
      end

      example "", vcr: { cassette_name: "success_fetching_followers_3" } do
        token = Rails.application.credentials.twitter[:bearer_token]
        condition = create(:twitter_search_condition,
          condition_type: :main,
          search_type: :following,
          content: "https://twitter.com/yyy_szk"
        )

        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r1 = searcher.search_users

        condition = create(:twitter_search_condition,
          condition_type: :narrowing,
          search_type: :following,
          content: "https://twitter.com/yyy_szk"
        )
        searcher = TwitterSearcher.new(
          condition,
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r2 = searcher.search_users
        r1.calc(r2)
        expect(r1.data.size).to(eq(364))
      end
    end
  end
end

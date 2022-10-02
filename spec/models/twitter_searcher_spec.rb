require "rails_helper"

RSpec.describe TwitterSearcher do
  describe "#search_users" do
    context "フォロワー検索の場合", vcr: { cassette_name: "success_fetching_followers" } do
      example do
        token = Rails.application.credentials.twitter[:bearer_token]
        searcher = TwitterSearcher.new(
          "1", # フォロワー検索
          "https://twitter.com/konzo_goriki", # 検索対象のユーザーのURL
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r1 = searcher.search_users
        # expect(r).to(eq([]))

        searcher = TwitterSearcher.new(
          "3", # フォロワー検索
          "https://twitter.com/yyy_szk", # 検索対象のユーザーのURL
          token # 開発者用のトークン
        )
        client = TwitterApiClient.new(access_token: token)
        allow(client).to(receive(:sleep))
        allow(searcher).to(receive(:client)).and_return(client)

        r2 = searcher.search_users

        # expect(r).to(eq([]))
        p r1.calc(r2).select { ["tatoyeba", "aim2bpg", "programd_taiga", "fushifushi_y", "komagata"].include? _1["username"] }

        # p r2.calc(r1).pluck("username")

      end
    end
  end
end

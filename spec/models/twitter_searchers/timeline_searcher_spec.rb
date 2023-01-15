require 'rails_helper'

RSpec.describe TwitterSearchers::TimelineSearcher, type: :model do
  dir = "twitter_searcher/timeline_searcher"

  let(:searcher) { TwitterSearchers::TimelineSearcher.new(twitter_search_condition) }
  
  describe "#search" do
    let(:twitter_search_condition) do
      process = create(:twitter_search_process,
        user: create(:user, twitter_access_token: Rails.application.credentials.twitter[:bearer_token])
      )

      create(:twitter_search_condition,
        twitter_search_process: process,
        condition_type: :main,
        type: "TwitterUserTimeline",
        content: "https://twitter.com/somonsism",
        num_of_days: 3
      )
    end

    example "somonsism の 直近3日のツイートを取得", vcr: { cassette_name: "#{dir}/fetch_timeline" } do
      expect(searcher.search.data).to(
        eq([
          {
            "created_at"=>"2023-01-14T00:18:58.000Z",
            "edit_history_tweet_ids"=>["1614054432035205121"],
            "id"=>"1614054432035205121",
            "public_metrics"=>{
              "impression_count"=>1021,
              "like_count"=>13,
              "quote_count"=>0,
              "reply_count"=>0,
              "retweet_count"=>0
            },
            "text"=>"友人関係を築くのに、同世代だけで群れるというのは楽だからやってしまいがちなのだけど、20歳くらい上とか下の人と友達として交流すると、とてもいい。\n\nそこができたら、次は国籍も仕事も年齢も性別も異なる人と利害関係のない友人関係を結べたら、自分の器も考え方も広がる。"
          },
          {
            "created_at"=>"2023-01-14T00:07:36.000Z",
            "edit_history_tweet_ids"=>["1614051571113000961"],
            "id"=>"1614051571113000961",
            "public_metrics"=>{
              "impression_count"=>958,
              "like_count"=>7,
              "quote_count"=>0,
              "reply_count"=>1,
              "retweet_count"=>0
            },
           "text"=>"「楽しく生きる」というコトバは、100%楽しいことだけで生きていくという意味ではなくて、楽しいことをできるだけ増やした生き方だと思ってる。\n\n面倒な仕事や人間関係をゼロにするのではなくて減らせばいい。\n\n減らし方は2つあって、単純に減らすか、自分が変わって楽しめるようにするか。"
          },
          {
            "created_at"=>"2023-01-12T23:57:47.000Z",
            "edit_history_tweet_ids"=>["1613686713104355329"],
            "id"=>"1613686713104355329",
            "public_metrics"=>{
              "impression_count"=>587,
              "like_count"=>5,
              "quote_count"=>0,
              "reply_count"=>0,
              "retweet_count"=>0
            },
            "text"=>"人生に必要な余裕って\nこういうことなのかもなあ。 https://t.co/S7XKuo4jgD"
          },
          {
            "created_at"=>"2023-01-14T00:12:56.000Z",
            "edit_history_tweet_ids"=>["1614052910857605121"],
            "id"=>"1614052910857605121",
            "public_metrics"=>{
              "impression_count"=>414,
              "like_count"=>2,
              "quote_count"=>0,
              "reply_count"=>0,
              "retweet_count"=>1
            },
           "text"=>"つまらないことを楽しくしたり、ストレスなことを減らすには、考え方を変えることで、かなり改善すると思う。\n\n仕事や勉強ならゲーム化したり、ゴールを立ててみたり、人間関係なら相手の面白さ良さを発見することに焦点を当てたり。\n\n同じ状況でも捉え方だけで視界は大きく変わるけど時間はかかる。"
          },
          {
            "created_at"=>"2023-01-13T00:24:29.000Z",
            "edit_history_tweet_ids"=>["1613693432438095874"],
            "id"=>"1613693432438095874",
            "public_metrics"=>
            {
              "impression_count"=>448,
              "like_count"=>1,
              "quote_count"=>0,
              "reply_count"=>0,
              "retweet_count"=>0
            },
           "text"=>"面白いなあ。\n現代の技術でも寿命100年のコンクリートを古代ローマでは2000年の寿命を可能にする技術があったとしたら、Dr.stoneのの世界観だなあ😊胸熱。\n\nhttps://t.co/XTo7Qz9Jwu"
          }
        ])
      )
    end
  end
end

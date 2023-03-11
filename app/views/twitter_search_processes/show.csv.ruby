require 'csv'
require 'nkf'

def users_csv_header
  %w[url name description following_count followers_count tweet_count]
end

def tweets_csv_header
  %w[url text created_at like_count retweet_count quote_count reply_count impression_count]
end

def header
  case @process_type
  when "user" then users_csv_header
  when "tweet" then tweets_csv_header
  end
end

def fetch_user_body(data)
  [
    "https://twitter.com/#{data["username"]}",
    data["name"],
    data["description"],
    data.dig("public_metrics", "following_count"),
    data.dig("public_metrics", "followers_count"),
    data.dig("public_metrics", "tweet_count"),
  ]
end

def fetch_tweet_body(data)
  username = @first_condition.content
    .sub(/^.*https:\/\/(.*\.)?twitter.com\//, "")
    .sub(/(\?.*)?$/, "")
    .strip

  [
    "https://twitter.com/#{username}/status/#{data["id"]}",
    data["text"],
    data["created_at"].in_time_zone,
    data.dig("public_metrics", "like_count"),
    data.dig("public_metrics", "retweet_count"),
    data.dig("public_metrics", "quote_count"),
    data.dig("public_metrics", "reply_count"),
    data.dig("public_metrics", "impression_count"),
  ]
end

def body(data)
  case @process_type
  when "user" then fetch_user_body(data)
  when "tweet" then fetch_tweet_body(data)
  end
end

csv_data = CSV.generate do |csv|
  csv << header
  @twitter_search_result_ids.each do |id|
    TwitterSearchResult.find(id).data.each do |data|
      csv << body(data)
    end
  end
end

NKF::nkf('--sjis -Lw', csv_data)

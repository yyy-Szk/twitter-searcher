class CreateTwitterSearchResults < ActiveRecord::Migration[6.1]
  def change
    # 多分だが、twitter_search_processとかの方が適切。んで、payloadをresultにする
    create_table :twitter_search_results do |t|
      t.integer :progress_rate, null: false, default: 0
      t.jsonb :payload, null: false, default: []

      t.timestamps
    end
  end
end

class CreateTwitterSearchResults < ActiveRecord::Migration[6.1]
  def change
    # 多分だが、twitter_search_processとかの方が適切。んで、payloadをresultにする
    create_table :twitter_search_results do |t|
      t.references :twitter_search_process, foreign_key: true, comment: "ツイッター検索プロセスID"
      t.jsonb :data, null: false, default: []

      t.timestamps
    end
  end
end

class CreateTwitterSearchConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_search_conditions do |t|
      t.references :twitter_search_result, foreign_key: true, comment: "ツイッター検索結果ID"
      t.integer :condition_type, comment: "条件の種類: 0: メイン条件, 1: 絞り込み条件"
      t.integer :search_type, null: false, comment: "検索条件（検索の種類）: 0: 直近1ヶ月にいいねしたユーザー, etc..."
      t.text :content , null: false, default: "", comment: "検索条件(検索の対象)"

      t.timestamps
    end
  end
end

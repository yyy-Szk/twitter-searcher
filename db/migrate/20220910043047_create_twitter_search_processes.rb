class CreateTwitterSearchProcesses < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_search_processes do |t|
      t.references :user, foreign_key: true, comment: "ユーザーID"
      t.integer :progress_rate, null: false, default: 0, comment: "進行率"
      t.string :error_class, comment: "エラークラス"
      t.string :error_message, comment: "エラーメッセージ"

      t.timestamps
    end
  end
end

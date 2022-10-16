class AddColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :uid, :string, comment: "ユーザーID"
    add_column :users, :password_digest, :string, comment: "パスワード"
    add_column :users, :twitter_refresh_token, :string, comment: "Twitterのリフレッシュトークン"
  end
end

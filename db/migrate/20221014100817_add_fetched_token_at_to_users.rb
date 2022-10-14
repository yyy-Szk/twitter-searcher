class AddFetchedTokenAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :fetched_access_token_at, :datetime, comment: "アクセストークン取得日時"
  end
end

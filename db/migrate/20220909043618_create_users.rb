class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :twitter_user_id, comment: "TwitterのユーザーID"
      t.string :twitter_username, comment: "Twitterのユーザー名"
      t.string :twitter_access_token, comment: "Twitterのアクセストークン"

      t.timestamps
    end
  end
end

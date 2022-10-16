class AddStatusToTwitterSearchProcesses < ActiveRecord::Migration[6.1]
  def change
    add_column :twitter_search_processes, :status, :integer, comment: "ステータス"
  end
end

class AddColumnToTwitterSearchProcesses < ActiveRecord::Migration[6.1]
  def change
    add_column :twitter_search_processes, :process_type, :integer, comment: "タイプ"
  end
end

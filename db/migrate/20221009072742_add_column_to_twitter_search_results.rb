class AddColumnToTwitterSearchResults < ActiveRecord::Migration[6.1]
  def change
    add_column :twitter_search_results, :error_class, :string
    add_column :twitter_search_results, :error_message, :string
  end
end

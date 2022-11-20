class RemoveUnnecessaryColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :twitter_search_conditions, :search_type, :integer
  end
end

class AddStiColumnsToTwitterSeachConditions < ActiveRecord::Migration[6.1]
  def change
    add_column :twitter_search_conditions, :type, :string, comment: "タイプ"
    add_column :twitter_search_conditions, :num_of_days, :integer, comment: "日数"
  end
end

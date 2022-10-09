class CreateTwitterSearchConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_search_conditions do |t|

      t.timestamps
    end
  end
end

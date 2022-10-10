class CreateTwitterSearchProcesses < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_search_processes do |t|

      t.timestamps
    end
  end
end

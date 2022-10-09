# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_10_09_072742) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "twitter_search_conditions", force: :cascade do |t|
    t.bigint "twitter_search_result_id", comment: "ツイッター検索結果ID"
    t.integer "condition_type", comment: "条件の種類: 0: メイン条件, 1: 絞り込み条件"
    t.integer "search_type", null: false, comment: "検索条件（検索の種類）: 0: 直近1ヶ月にいいねしたユーザー, etc..."
    t.text "content", default: "", null: false, comment: "検索条件(検索の対象)"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["twitter_search_result_id"], name: "index_twitter_search_conditions_on_twitter_search_result_id"
  end

  create_table "twitter_search_results", force: :cascade do |t|
    t.integer "progress_rate", default: 0, null: false
    t.jsonb "payload", default: [], null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "error_class"
    t.string "error_message"
  end

  add_foreign_key "twitter_search_conditions", "twitter_search_results"
end

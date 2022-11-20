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

ActiveRecord::Schema.define(version: 2022_11_20_092626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "twitter_search_conditions", force: :cascade do |t|
    t.bigint "twitter_search_process_id", comment: "ツイッター検索プロセスID"
    t.integer "condition_type", comment: "条件の種類: 0: メイン条件, 1: 絞り込み条件"
    t.text "content", default: "", null: false, comment: "検索条件(検索の対象)"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", comment: "タイプ"
    t.integer "num_of_days", comment: "日数"
    t.index ["twitter_search_process_id"], name: "index_twitter_search_conditions_on_twitter_search_process_id"
  end

  create_table "twitter_search_processes", force: :cascade do |t|
    t.bigint "user_id", comment: "ユーザーID"
    t.integer "progress_rate", default: 0, null: false, comment: "進行率"
    t.string "error_class", comment: "エラークラス"
    t.string "error_message", comment: "エラーメッセージ"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", comment: "ステータス"
    t.index ["user_id"], name: "index_twitter_search_processes_on_user_id"
  end

  create_table "twitter_search_results", force: :cascade do |t|
    t.bigint "twitter_search_process_id", comment: "ツイッター検索プロセスID"
    t.jsonb "data", default: [], null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["twitter_search_process_id"], name: "index_twitter_search_results_on_twitter_search_process_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "twitter_user_id", comment: "TwitterのユーザーID"
    t.string "twitter_username", comment: "Twitterのユーザー名"
    t.string "twitter_access_token", comment: "Twitterのアクセストークン"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uid", comment: "ユーザーID"
    t.string "password_digest", comment: "パスワード"
    t.string "twitter_refresh_token", comment: "Twitterのリフレッシュトークン"
    t.datetime "fetched_access_token_at", comment: "アクセストークン取得日時"
  end

  add_foreign_key "twitter_search_conditions", "twitter_search_processes"
  add_foreign_key "twitter_search_processes", "users"
  add_foreign_key "twitter_search_results", "twitter_search_processes"
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180713104634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "unlock_token"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.string "ethereum_wallet"
    t.string "password_digest"
    t.string "email_confirm_token"
    t.string "first_name"
    t.string "last_name"
    t.string "image_id"
    t.string "image_filename"
    t.string "image_content_size"
    t.string "image_content_type"
    t.string "nickname"
    t.string "country"
    t.date "date_of_birth"
    t.string "public_address"
    t.string "nonce"
    t.string "network_id"
    t.boolean "system_email", default: false
    t.index "lower((email)::text)", name: "index_accounts_on_lowercase_email", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_accounts_on_last_logout_at_and_last_activity_at"
    t.index ["public_address"], name: "index_accounts_on_public_address"
    t.index ["remember_me_token"], name: "index_accounts_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token"
  end

  create_table "authentication_teams", force: :cascade do |t|
    t.integer "authentication_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.integer "team_id"
    t.boolean "manager", default: false
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "provider", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uid", null: false
    t.string "token"
    t.string "slack_user_name"
    t.string "slack_first_name"
    t.string "slack_last_name"
    t.string "slack_image_32_url"
    t.jsonb "oauth_response"
    t.string "email"
    t.string "confirm_token"
    t.index ["account_id"], name: "index_authentications_on_account_id"
  end

  create_table "award_types", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "community_awardable", default: false, null: false
    t.text "description"
    t.boolean "disabled"
    t.index ["project_id"], name: "index_award_types_on_project_id"
  end

  create_table "awards", id: :serial, force: :cascade do |t|
    t.integer "issuer_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "award_type_id", null: false
    t.integer "authentication_id"
    t.string "ethereum_transaction_address"
    t.text "proof_id", null: false
    t.string "proof_link"
    t.decimal "quantity", default: "1.0"
    t.integer "total_amount"
    t.integer "unit_amount"
    t.integer "account_id"
    t.integer "channel_id"
    t.string "uid"
    t.string "confirm_token"
    t.string "email"
    t.index ["award_type_id"], name: "index_awards_on_award_type_id"
  end

  create_table "channels", force: :cascade do |t|
    t.integer "project_id"
    t.integer "team_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "issuer_id"
    t.integer "account_id"
    t.decimal "total_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "share_value"
    t.integer "quantity_redeemed"
    t.decimal "transaction_fee"
    t.decimal "total_payment"
    t.text "transaction_reference"
    t.string "currency"
    t.integer "status", default: 0
    t.boolean "reconciled", default: false
    t.index ["project_id"], name: "index_payments_on_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "tracker"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false, null: false
    t.integer "account_id", null: false
    t.string "slack_team_id"
    t.string "image_id"
    t.string "slack_channel"
    t.integer "maximum_tokens", default: 0, null: false
    t.text "contributor_agreement_url"
    t.text "video_url"
    t.string "ethereum_contract_address"
    t.boolean "ethereum_enabled", default: false
    t.integer "payment_type", default: 1
    t.boolean "exclusive_contributions"
    t.string "legal_project_owner"
    t.boolean "require_confidentiality"
    t.decimal "royalty_percentage", precision: 16, scale: 13
    t.integer "maximum_royalties_per_month"
    t.boolean "license_finalized", default: false, null: false
    t.integer "denomination", default: 0, null: false
    t.datetime "revenue_sharing_end_date"
    t.integer "featured"
    t.string "image_filename"
    t.string "image_content_size"
    t.string "image_content_type"
    t.string "long_id"
    t.integer "visibility", default: 0
    t.string "token_symbol"
    t.string "ethereum_network"
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["public"], name: "index_projects_on_public"
    t.index ["slack_team_id", "public"], name: "index_projects_on_slack_team_id_and_public"
  end

  create_table "revenues", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "currency"
    t.decimal "amount"
    t.text "comment"
    t.text "transaction_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recorded_by_id"
    t.index ["project_id"], name: "index_revenues_on_project_id"
    t.index ["recorded_by_id"], name: "index_revenues_on_recorded_by_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_id"
    t.string "name"
    t.string "domain"
    t.string "provider"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

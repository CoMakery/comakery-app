# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_28_115845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_token_records", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "token_id"
    t.bigint "reg_group_id"
    t.decimal "max_balance", precision: 78
    t.boolean "account_frozen"
    t.decimal "lockup_until", precision: 78
    t.datetime "synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance", precision: 78
    t.integer "status", default: 0
    t.index ["account_id"], name: "index_account_token_records_on_account_id"
    t.index ["reg_group_id"], name: "index_account_token_records_on_reg_group_id"
    t.index ["token_id"], name: "index_account_token_records_on_token_id"
  end

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
    t.string "public_address"
    t.string "nonce"
    t.string "network_id"
    t.boolean "system_email", default: false
    t.string "country"
    t.date "date_of_birth"
    t.date "agreed_to_user_agreement"
    t.boolean "new_award_notice", default: false
    t.boolean "contributor_form", default: false
    t.string "qtum_wallet"
    t.boolean "comakery_admin", default: false
    t.string "cardano_wallet"
    t.string "bitcoin_wallet"
    t.string "eos_wallet"
    t.string "deprecated_specialty"
    t.string "occupation"
    t.string "linkedin_url"
    t.string "github_url"
    t.string "dribble_url"
    t.string "behance_url"
    t.string "tezos_wallet"
    t.integer "specialty_id"
    t.bigint "latest_verification_id"
    t.string "managed_account_id", limit: 256
    t.bigint "managed_mission_id"
    t.string "ethereum_auth_address", limit: 42
    t.string "constellation_wallet", limit: 40
    t.index ["last_logout_at", "last_activity_at"], name: "index_accounts_on_last_logout_at_and_last_activity_at"
    t.index ["managed_mission_id", "managed_account_id"], name: "index_accounts_on_managed_mission_id_and_managed_account_id", unique: true
    t.index ["managed_mission_id"], name: "index_accounts_on_managed_mission_id"
    t.index ["public_address"], name: "index_accounts_on_public_address"
    t.index ["remember_me_token"], name: "index_accounts_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token"
  end

  create_table "accounts_projects", id: false, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "project_id", null: false
    t.index ["account_id", "project_id"], name: "index_accounts_projects_on_account_id_and_project_id"
    t.index ["project_id", "account_id"], name: "index_accounts_projects_on_project_id_and_account_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_postgresql_files", force: :cascade do |t|
    t.oid "oid"
    t.string "key"
    t.index ["key"], name: "index_active_storage_postgresql_files_on_key", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "api_authorizable_type"
    t.bigint "api_authorizable_id"
    t.string "key", limit: 32
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_authorizable_type", "api_authorizable_id"], name: "index_api_keys_on_api_authorizable_type_and_api_authorizable_id"
  end

  create_table "api_request_logs", force: :cascade do |t|
    t.inet "ip", null: false
    t.string "signature", null: false
    t.jsonb "body", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_api_request_logs_on_created_at"
    t.index ["signature"], name: "index_api_request_logs_on_signature", unique: true
  end

  create_table "authentication_teams", force: :cascade do |t|
    t.integer "authentication_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.integer "team_id"
    t.boolean "manager", default: false
    t.index ["account_id"], name: "index_authentication_teams_on_account_id"
    t.index ["authentication_id"], name: "index_authentication_teams_on_authentication_id"
    t.index ["team_id"], name: "index_authentication_teams_on_team_id"
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
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "community_awardable", default: false, null: false
    t.text "description"
    t.boolean "disabled"
    t.text "goal"
    t.string "specialty"
    t.integer "specialty_id"
    t.string "diagram_id"
    t.string "diagram_filename"
    t.string "diagram_content_size"
    t.string "diagram_content_type"
    t.boolean "published", default: false
    t.integer "state", default: 0
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
    t.decimal "total_amount"
    t.integer "unit_amount"
    t.integer "account_id"
    t.integer "channel_id"
    t.string "uid"
    t.string "confirm_token"
    t.string "email"
    t.string "name"
    t.text "why"
    t.text "requirements"
    t.integer "status", default: 0
    t.decimal "amount"
    t.text "message"
    t.string "image_id"
    t.string "image_filename"
    t.string "image_content_size"
    t.string "image_content_type"
    t.integer "experience_level", default: 0
    t.string "submission_url"
    t.string "submission_comment"
    t.string "submission_image_id"
    t.string "submission_image_filename"
    t.string "submission_image_content_size"
    t.string "submission_image_content_type"
    t.integer "number_of_assignments", default: 1
    t.integer "cloned_on_assignment_from_id"
    t.integer "number_of_assignments_per_user", default: 1
    t.bigint "specialty_id"
    t.string "agreed_to_license_hash"
    t.datetime "expires_at"
    t.integer "expires_in_days", default: 10
    t.datetime "notify_on_expiration_at"
    t.integer "assignments_count", default: 0
    t.datetime "transferred_at"
    t.integer "source", default: 0
    t.boolean "transaction_success"
    t.string "transaction_error"
    t.bigint "transfer_type_id"
    t.index ["award_type_id"], name: "index_awards_on_award_type_id"
    t.index ["specialty_id"], name: "index_awards_on_specialty_id"
    t.index ["transfer_type_id"], name: "index_awards_on_transfer_type_id"
  end

  create_table "balances", force: :cascade do |t|
    t.bigint "wallet_id"
    t.bigint "token_id"
    t.bigint "base_unit_value", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token_id"], name: "index_balances_on_token_id"
    t.index ["wallet_id", "token_id"], name: "idx_walled_id_token_id", unique: true
    t.index ["wallet_id"], name: "index_balances_on_wallet_id"
  end

  create_table "blockchain_transaction_updates", force: :cascade do |t|
    t.bigint "blockchain_transaction_id"
    t.integer "status", default: 0
    t.string "status_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blockchain_transaction_id"], name: "index_blockchain_tx_updates_on_blockchain_tx_id"
  end

  create_table "blockchain_transactions", force: :cascade do |t|
    t.bigint "award_id"
    t.decimal "amount", precision: 78
    t.string "source"
    t.string "destination"
    t.integer "nonce"
    t.string "contract_address"
    t.integer "network"
    t.string "tx_hash"
    t.string "tx_raw"
    t.integer "status", default: 0
    t.string "status_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "synced_at"
    t.integer "number_of_syncs", default: 0
    t.decimal "current_block", precision: 78
    t.string "blockchain_transactable_type"
    t.bigint "blockchain_transactable_id"
    t.string "type", default: "BlockchainTransactionAward", null: false
    t.bigint "token_id"
    t.index ["award_id"], name: "index_blockchain_transactions_on_award_id"
    t.index ["blockchain_transactable_type", "blockchain_transactable_id"], name: "index_bc_txs_on_bc_txble_type_and_bc_txble_id"
    t.index ["token_id"], name: "index_blockchain_transactions_on_token_id"
  end

  create_table "channels", force: :cascade do |t|
    t.integer "project_id"
    t.integer "team_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel_id"
    t.string "discord_invite_code"
    t.datetime "discord_invite_created_at"
    t.index ["project_id"], name: "index_channels_on_project_id"
    t.index ["team_id"], name: "index_channels_on_team_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "specialty_id"
    t.integer "level", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_experiences_on_account_id"
    t.index ["specialty_id"], name: "index_experiences_on_specialty_id"
  end

  create_table "interests", force: :cascade do |t|
    t.bigint "account_id"
    t.string "protocol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.integer "specialty_id"
    t.index ["account_id"], name: "index_interests_on_account_id"
    t.index ["project_id"], name: "index_interests_on_project_id"
  end

  create_table "missions", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "subtitle", limit: 140
    t.text "description"
    t.string "logo_id"
    t.string "logo_filename"
    t.string "logo_content_size"
    t.string "logo_content_type"
    t.string "image_id"
    t.string "image_filename"
    t.string "image_content_size"
    t.string "image_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "token_id"
    t.integer "status", default: 0
    t.integer "display_order"
    t.boolean "whitelabel", default: false, null: false
    t.string "whitelabel_domain"
    t.string "whitelabel_logo_id"
    t.string "whitelabel_logo_filename"
    t.string "whitelabel_logo_content_size"
    t.string "whitelabel_logo_content_type"
    t.string "whitelabel_logo_dark_id"
    t.string "whitelabel_logo_dark_filename"
    t.string "whitelabel_logo_dark_content_size"
    t.string "whitelabel_logo_dark_content_type"
    t.string "whitelabel_favicon_id"
    t.string "whitelabel_favicon_filename"
    t.string "whitelabel_favicon_content_size"
    t.string "whitelabel_favicon_content_type"
    t.string "whitelabel_contact_email"
    t.string "whitelabel_api_public_key"
    t.string "whitelabel_api_key"
    t.index ["token_id"], name: "index_missions_on_token_id"
  end

  create_table "ore_id_accounts", force: :cascade do |t|
    t.string "account_name"
    t.bigint "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.integer "provisioning_stage", default: 0, null: false
    t.string "temp_password"
    t.index ["account_id"], name: "index_ore_id_accounts_on_account_id"
    t.index ["account_name"], name: "index_ore_id_accounts_on_account_name", unique: true
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
    t.decimal "maximum_tokens", default: "0.0"
    t.text "contributor_agreement_url"
    t.text "video_url"
    t.string "ethereum_contract_address"
    t.boolean "ethereum_enabled", default: false
    t.integer "payment_type", default: 1
    t.boolean "exclusive_contributions", default: true
    t.string "legal_project_owner"
    t.boolean "require_confidentiality", default: true
    t.decimal "royalty_percentage", precision: 16, scale: 13
    t.integer "maximum_royalties_per_month"
    t.boolean "license_finalized", default: false, null: false
    t.integer "denomination", default: 0, null: false
    t.datetime "revenue_sharing_end_date"
    t.integer "featured"
    t.string "image_filename"
    t.string "image_content_size"
    t.string "image_content_type"
    t.boolean "archived", default: false
    t.string "long_id"
    t.integer "visibility", default: 1
    t.string "token_symbol"
    t.string "ethereum_network"
    t.integer "decimal_places"
    t.string "coin_type"
    t.string "blockchain_network"
    t.string "contract_address"
    t.bigint "mission_id"
    t.integer "status", default: 1
    t.bigint "token_id"
    t.string "square_image_id"
    t.string "square_image_filename"
    t.string "square_image_content_size"
    t.string "square_image_content_type"
    t.string "panoramic_image_id"
    t.string "panoramic_image_filename"
    t.string "panoramic_image_content_size"
    t.string "panoramic_image_content_type"
    t.boolean "confidentiality", default: true
    t.string "agreed_to_license_hash"
    t.boolean "display_team", default: true
    t.bigint "interests_count"
    t.boolean "whitelabel", default: false, null: false
    t.boolean "auto_add_interest", default: false, null: false
    t.text "github_url"
    t.text "documentation_url"
    t.text "getting_started_url"
    t.text "governance_url"
    t.text "funding_url"
    t.text "video_conference_url"
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["mission_id"], name: "index_projects_on_mission_id"
    t.index ["public"], name: "index_projects_on_public"
    t.index ["slack_team_id", "public"], name: "index_projects_on_slack_team_id_and_public"
    t.index ["token_id"], name: "index_projects_on_token_id"
  end

  create_table "reg_groups", force: :cascade do |t|
    t.bigint "token_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "blockchain_id", precision: 78
    t.index ["blockchain_id"], name: "index_reg_groups_on_blockchain_id"
    t.index ["token_id"], name: "index_reg_groups_on_token_id"
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

  create_table "specialties", force: :cascade do |t|
    t.string "name"
  end

  create_table "synchronisations", force: :cascade do |t|
    t.string "synchronisable_type"
    t.bigint "synchronisable_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["synchronisable_type", "synchronisable_id"], name: "idx_syncs_on_sync_type_and_sync_id"
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

  create_table "token_opt_ins", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "token_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token_id"], name: "index_token_opt_ins_on_token_id"
    t.index ["wallet_id", "token_id"], name: "index_token_opt_ins_on_wallet_id_and_token_id", unique: true
    t.index ["wallet_id"], name: "index_token_opt_ins_on_wallet_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "name"
    t.string "coin_type"
    t.integer "denomination", default: 0, null: false
    t.boolean "ethereum_enabled", default: false
    t.string "ethereum_network"
    t.string "blockchain_network"
    t.string "contract_address"
    t.string "ethereum_contract_address"
    t.string "symbol"
    t.integer "decimal_places"
    t.string "logo_image_id"
    t.string "logo_image_filename"
    t.string "logo_image_content_size"
    t.string "logo_image_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "unlisted", default: false
    t.boolean "token_frozen", default: false
    t.datetime "synced_at"
    t.integer "_blockchain", default: 0, null: false
    t.integer "_token_type", default: 0, null: false
  end

  create_table "transfer_rules", force: :cascade do |t|
    t.bigint "token_id"
    t.bigint "sending_group_id"
    t.bigint "receiving_group_id"
    t.decimal "lockup_until", precision: 78
    t.datetime "synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["token_id"], name: "index_transfer_rules_on_token_id"
  end

  create_table "transfer_types", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.boolean "default", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_transfer_types_on_project_id"
  end

  create_table "unsubscriptions", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_unsubscriptions_on_email", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "provider_id"
    t.boolean "passed"
    t.bigint "max_investment_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "verification_type", default: 0, null: false
    t.index ["account_id"], name: "index_verifications_on_account_id"
    t.index ["provider_id"], name: "index_verifications_on_provider_id"
  end

  create_table "wallet_provisions", force: :cascade do |t|
    t.bigint "wallet_id"
    t.bigint "token_id"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token_id"], name: "index_wallet_provisions_on_token_id"
    t.index ["wallet_id"], name: "index_wallet_provisions_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "account_id"
    t.string "address"
    t.integer "_blockchain", default: 0, null: false
    t.integer "source", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "ore_id_account_id"
    t.index ["_blockchain", "account_id"], name: "idx_blockchain_account_id", unique: true
    t.index ["account_id"], name: "index_wallets_on_account_id"
    t.index ["ore_id_account_id"], name: "index_wallets_on_ore_id_account_id"
  end

  add_foreign_key "account_token_records", "accounts"
  add_foreign_key "account_token_records", "reg_groups"
  add_foreign_key "account_token_records", "tokens"
  add_foreign_key "accounts", "missions", column: "managed_mission_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "awards", "specialties"
  add_foreign_key "awards", "transfer_types"
  add_foreign_key "balances", "tokens"
  add_foreign_key "balances", "wallets"
  add_foreign_key "blockchain_transaction_updates", "blockchain_transactions"
  add_foreign_key "blockchain_transactions", "awards"
  add_foreign_key "blockchain_transactions", "tokens"
  add_foreign_key "experiences", "accounts"
  add_foreign_key "experiences", "specialties"
  add_foreign_key "interests", "accounts"
  add_foreign_key "ore_id_accounts", "accounts"
  add_foreign_key "projects", "tokens"
  add_foreign_key "reg_groups", "tokens"
  add_foreign_key "token_opt_ins", "tokens"
  add_foreign_key "token_opt_ins", "wallets"
  add_foreign_key "transfer_rules", "tokens"
  add_foreign_key "transfer_types", "projects"
  add_foreign_key "verifications", "accounts"
  add_foreign_key "wallet_provisions", "tokens"
  add_foreign_key "wallet_provisions", "wallets"
  add_foreign_key "wallets", "accounts"
  add_foreign_key "wallets", "ore_id_accounts"
end

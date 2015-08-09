# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150804030912) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_roles", force: true do |t|
    t.integer  "role_id",    limit: 8
    t.integer  "action_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", force: true do |t|
    t.string   "action_name"
    t.integer  "controller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "human_name"
  end

  add_index "actions", ["action_name"], name: "index_actions_on_action_name", using: :btree

  create_table "activities", force: true do |t|
    t.integer  "outcome_id"
    t.text     "description"
    t.text     "performance_indicator"
    t.text     "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress"
  end

  create_table "controllers", force: true do |t|
    t.string   "controller_name"
    t.datetime "last_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controllers", ["controller_name"], name: "index_controllers_on_controller_name", using: :btree

  create_table "document_groups", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "internal_documents", force: true do |t|
    t.string   "file_id"
    t.string   "title"
    t.integer  "filesize"
    t.string   "original_filename"
    t.integer  "revision_major"
    t.integer  "revision_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastModifiedDate"
    t.string   "original_type"
    t.integer  "document_group_id"
    t.integer  "user_id"
  end

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "contacts"
    t.string   "state"
  end

  create_table "outcomes", force: true do |t|
    t.integer  "planned_result_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planned_results", force: true do |t|
    t.string   "description"
    t.integer  "strategic_priority_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders", force: true do |t|
    t.string   "text"
    t.string   "reminder_type"
    t.date     "start_date"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders_users", id: false, force: true do |t|
    t.integer "reminder_id"
    t.integer "user_id"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "session_id"
    t.datetime "login_date"
    t.datetime "logout_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "strategic_plans", force: true do |t|
    t.date     "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "strategic_priorities", force: true do |t|
    t.integer  "priority_level"
    t.text     "description"
    t.integer  "strategic_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: true do |t|
    t.integer  "role_id",    limit: 8, null: false
    t.integer  "user_id",    limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "useractions", force: true do |t|
    t.integer  "user_id"
    t.integer  "action_id"
    t.string   "type"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       limit: 40
    t.boolean  "enabled",                              default: true
    t.string   "firstName"
    t.string   "lastName"
    t.string   "type"
    t.string   "status",                               default: "created"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "users", ["login"], name: "index_users_on_login", using: :btree

end

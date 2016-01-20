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

ActiveRecord::Schema.define(version: 20160120210924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_roles", force: :cascade do |t|
    t.integer  "role_id",    limit: 8
    t.integer  "action_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", force: :cascade do |t|
    t.string   "action_name",   limit: 255
    t.integer  "controller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "human_name",    limit: 255
  end

  add_index "actions", ["action_name"], name: "index_actions_on_action_name", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "outcome_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress",    limit: 255
    t.string   "index",       limit: 10
  end

  create_table "areas", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audience_types", force: :cascade do |t|
    t.string   "short_type"
    t.string   "long_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "controllers", force: :cascade do |t|
    t.string   "controller_name", limit: 255
    t.datetime "last_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controllers", ["controller_name"], name: "index_controllers_on_controller_name", using: :btree

  create_table "document_groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impact_ratings", force: :cascade do |t|
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "internal_documents", force: :cascade do |t|
    t.string   "file_id",           limit: 255
    t.string   "title",             limit: 255
    t.integer  "filesize"
    t.string   "original_filename", limit: 255
    t.integer  "revision_major"
    t.integer  "revision_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastModifiedDate"
    t.string   "original_type",     limit: 255
    t.integer  "document_group_id"
    t.integer  "user_id"
  end

  create_table "media_appearance_performance_indicators", force: :cascade do |t|
    t.integer  "media_appearance_id"
    t.integer  "performance_indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_appearances", force: :cascade do |t|
    t.string   "file_id",               limit: 255
    t.integer  "filesize"
    t.string   "original_filename",     limit: 255
    t.string   "original_type",         limit: 255
    t.integer  "user_id"
    t.string   "url"
    t.string   "title"
    t.integer  "affected_people_count"
    t.float    "violation_coefficient"
    t.integer  "positivity_rating_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "violation_severity_id"
    t.datetime "lastModifiedDate"
    t.text     "article_link"
  end

  create_table "media_areas", force: :cascade do |t|
    t.integer  "media_appearance_id"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_subareas", force: :cascade do |t|
    t.integer  "media_appearance_id"
    t.integer  "subarea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: :cascade do |t|
    t.text     "text"
    t.integer  "notable_id"
    t.integer  "author_id"
    t.integer  "editor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "notable_type"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "street",     limit: 255
    t.string   "city",       limit: 255
    t.string   "zip",        limit: 255
    t.string   "phone",      limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "contacts",   limit: 255
    t.string   "state",      limit: 255
  end

  create_table "outcomes", force: :cascade do |t|
    t.integer  "planned_result_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "index",             limit: 10
  end

  create_table "outreach_event_areas", force: :cascade do |t|
    t.integer  "outreach_event_id"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_event_documents", force: :cascade do |t|
    t.integer  "outreach_event_id"
    t.string   "file_id",           limit: 255
    t.integer  "file_size"
    t.string   "file_filename",     limit: 255
    t.string   "file_content_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_event_performance_indicators", force: :cascade do |t|
    t.integer  "outreach_event_id"
    t.integer  "performance_indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_event_subareas", force: :cascade do |t|
    t.integer  "outreach_event_id"
    t.integer  "subarea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_events", force: :cascade do |t|
    t.string   "title"
    t.datetime "event_date"
    t.integer  "audience_type_id"
    t.string   "audience_name"
    t.integer  "participant_count"
    t.integer  "affected_people_count"
    t.text     "description"
    t.integer  "impact_rating_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "performance_indicators", force: :cascade do |t|
    t.integer  "activity_id"
    t.text     "description"
    t.text     "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "index",       limit: 10
  end

  create_table "planned_results", force: :cascade do |t|
    t.string   "description",           limit: 255
    t.integer  "strategic_priority_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "index",                 limit: 10
  end

  create_table "positivity_ratings", force: :cascade do |t|
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders", force: :cascade do |t|
    t.string   "text",            limit: 255
    t.string   "reminder_type",   limit: 255
    t.date     "start_date"
    t.integer  "remindable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remindable_type"
  end

  create_table "reminders_users", id: false, force: :cascade do |t|
    t.integer "reminder_id"
    t.integer "user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "short_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "session_id",  limit: 255
    t.datetime "login_date"
    t.datetime "logout_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255, null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "strategic_plans", force: :cascade do |t|
    t.date     "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "strategic_priorities", force: :cascade do |t|
    t.integer  "priority_level"
    t.text     "description"
    t.integer  "strategic_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subareas", force: :cascade do |t|
    t.text     "name"
    t.text     "full_name"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "role_id",    limit: 8, null: false
    t.integer  "user_id",    limit: 8, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "useractions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "action_id"
    t.string   "type",       limit: 255
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       limit: 40
    t.boolean  "enabled",                               default: true
    t.string   "firstName",                 limit: 255
    t.string   "lastName",                  limit: 255
    t.string   "type",                      limit: 255
    t.string   "status",                    limit: 255, default: "created"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "users", ["login"], name: "index_users_on_login", using: :btree

  create_table "violation_severities", force: :cascade do |t|
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

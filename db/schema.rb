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

ActiveRecord::Schema.define(version: 20190616191334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_roles", id: :serial, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "action_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", id: :serial, force: :cascade do |t|
    t.string "action_name", limit: 255
    t.integer "controller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "human_name", limit: 255
    t.index ["action_name"], name: "index_actions_on_action_name"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "outcome_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "progress", limit: 255
    t.string "index", limit: 10
  end

  create_table "advisory_council_documents", id: :serial, force: :cascade do |t|
    t.string "file_id", limit: 255
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.integer "revision_major"
    t.integer "revision_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastModifiedDate"
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.string "type"
    t.datetime "date"
  end

  create_table "advisory_council_issues", id: :serial, force: :cascade do |t|
    t.string "file_id", limit: 255
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.string "title"
    t.datetime "lastModifiedDate"
    t.text "article_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advisory_council_members", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "organization"
    t.string "department"
    t.string "mobile_phone"
    t.string "office_phone"
    t.string "home_phone"
    t.string "email"
    t.string "alternate_email"
    t.string "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_data_backups", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "application_data_backups_glacier_file_archives", id: false, force: :cascade do |t|
    t.bigint "application_data_backup_id", null: false
    t.bigint "glacier_file_archive_id", null: false
  end

  create_table "areas", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assigns", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audience_types", id: :serial, force: :cascade do |t|
    t.string "short_type"
    t.string "long_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communicants", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title_key"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.integer "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communication_communicants", id: :serial, force: :cascade do |t|
    t.integer "communication_id"
    t.integer "communicant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communication_documents", id: :serial, force: :cascade do |t|
    t.integer "communication_id"
    t.string "file_id", limit: 255
    t.string "title", limit: 255
    t.integer "filesize"
    t.string "filename", limit: 255
    t.datetime "lastModifiedDate"
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communications", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "user_id"
    t.string "direction"
    t.string "mode"
    t.datetime "date"
    t.text "note"
  end

  create_table "complaint_agencies", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaint_bases", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaint_complaint_bases", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "complaint_basis_id"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaint_conventions", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "convention_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaint_documents", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.string "file_id", limit: 255
    t.string "title", limit: 255
    t.integer "filesize"
    t.string "filename", limit: 255
    t.datetime "lastModifiedDate"
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaint_mandates", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "mandate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaint_statuses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaints", id: :serial, force: :cascade do |t|
    t.string "case_reference"
    t.string "village"
    t.string "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "desired_outcome"
    t.boolean "complained_to_subject_agency"
    t.date "date_received"
    t.boolean "imported", default: false
    t.integer "mandate_id"
    t.string "email"
    t.string "gender", limit: 1
    t.date "dob"
    t.text "details"
    t.string "firstName"
    t.string "lastName"
    t.string "chiefly_title"
    t.string "occupation"
    t.string "employer"
  end

  create_table "controllers", id: :serial, force: :cascade do |t|
    t.string "controller_name", limit: 255
    t.datetime "last_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["controller_name"], name: "index_controllers_on_controller_name"
  end

  create_table "conventions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csp_reports", id: :serial, force: :cascade do |t|
    t.string "document_uri"
    t.string "referrer"
    t.string "violated_directive"
    t.string "effective_directive"
    t.string "source_file"
    t.text "original_policy"
    t.text "blocked_uri"
    t.integer "status_code", default: 0
    t.integer "line_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "document_groups", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.integer "archive_doc_count", default: 0
    t.string "type"
  end

  create_table "file_monitors", id: :serial, force: :cascade do |t|
    t.integer "indicator_id"
    t.integer "user_id"
    t.datetime "lastModifiedDate"
    t.string "file_id", limit: 255
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.string "original_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "glacier_archives", id: :serial, force: :cascade do |t|
    t.text "description"
    t.text "archive_id"
    t.text "checksum"
    t.text "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "notification"
    t.string "archive_retrieval_job_id"
    t.integer "application_data_backup_id"
    t.string "type"
    t.string "filename"
  end

  create_table "headings", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "human_rights_attributes", id: :serial, force: :cascade do |t|
    t.string "description"
    t.integer "heading_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "icc_reference_documents", id: :serial, force: :cascade do |t|
    t.string "source_url"
    t.string "title"
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.string "file_id"
    t.datetime "lastModifiedDate"
  end

  create_table "indicators", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "human_rights_attribute_id"
    t.integer "heading_id"
    t.string "nature"
    t.string "monitor_format"
    t.string "numeric_monitor_explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "internal_documents", id: :serial, force: :cascade do |t|
    t.string "file_id", limit: 255
    t.string "title", limit: 255
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.integer "revision_major"
    t.integer "revision_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastModifiedDate"
    t.string "original_type", limit: 255
    t.integer "document_group_id"
    t.integer "user_id"
    t.string "type"
  end

  create_table "issue_areas", id: :serial, force: :cascade do |t|
    t.integer "advisory_council_issue_id"
    t.integer "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issue_subareas", id: :serial, force: :cascade do |t|
    t.integer "advisory_council_issue_id"
    t.integer "subarea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mandates", id: :serial, force: :cascade do |t|
    t.string "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_appearance_performance_indicators", id: :serial, force: :cascade do |t|
    t.integer "media_appearance_id"
    t.integer "performance_indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_appearances", id: :serial, force: :cascade do |t|
    t.string "file_id", limit: 255
    t.integer "filesize"
    t.string "original_filename", limit: 255
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.string "url"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastModifiedDate"
    t.text "article_link"
  end

  create_table "media_areas", id: :serial, force: :cascade do |t|
    t.integer "media_appearance_id"
    t.integer "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_subareas", id: :serial, force: :cascade do |t|
    t.integer "media_appearance_id"
    t.integer "subarea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "notable_id"
    t.integer "author_id"
    t.integer "editor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notable_type"
  end

  create_table "numeric_monitors", id: :serial, force: :cascade do |t|
    t.integer "indicator_id"
    t.integer "author_id"
    t.datetime "date"
    t.integer "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "street", limit: 255
    t.string "city", limit: 255
    t.string "zip", limit: 255
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contacts", limit: 255
    t.string "state", limit: 255
  end

  create_table "outcomes", id: :serial, force: :cascade do |t|
    t.integer "planned_result_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "index", limit: 10
  end

  create_table "performance_indicators", id: :serial, force: :cascade do |t|
    t.integer "activity_id"
    t.text "description"
    t.text "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "index", limit: 10
  end

  create_table "planned_results", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255
    t.integer "strategic_priority_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "index", limit: 10
  end

  create_table "project_documents", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "file_id", limit: 255
    t.string "title", limit: 255
    t.integer "filesize"
    t.string "filename", limit: 255
    t.datetime "lastModifiedDate"
    t.string "original_type", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_mandates", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "mandate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_named_documents", id: :serial, force: :cascade do |t|
  end

  create_table "project_performance_indicators", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "performance_indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_project_types", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "project_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "mandate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders", id: :serial, force: :cascade do |t|
    t.string "text", limit: 255
    t.string "reminder_type", limit: 255
    t.integer "remindable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remindable_type"
    t.datetime "start_date"
    t.datetime "next"
    t.integer "user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "short_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "session_id", limit: 255
    t.datetime "login_date"
    t.datetime "logout_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "expired", default: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "var", limit: 255, null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "status_changes", id: :serial, force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "complaint_status_id"
    t.datetime "change_date"
  end

  create_table "strategic_plans", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
  end

  create_table "strategic_priorities", id: :serial, force: :cascade do |t|
    t.integer "priority_level"
    t.text "description"
    t.integer "strategic_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subareas", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "full_name"
    t.integer "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "text_monitors", id: :serial, force: :cascade do |t|
    t.integer "indicator_id"
    t.integer "author_id"
    t.datetime "date"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "useractions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "action_id"
    t.string "type", limit: 255
    t.text "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", limit: 255
    t.string "email", limit: 255
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.string "activation_code", limit: 40
    t.datetime "activated_at"
    t.string "password_reset_code", limit: 40
    t.boolean "enabled", default: true
    t.string "firstName", limit: 255
    t.string "lastName", limit: 255
    t.string "type", limit: 255
    t.string "status", limit: 255, default: "created"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_id"
    t.string "challenge"
    t.datetime "challenge_timestamp"
    t.string "public_key"
    t.string "public_key_handle"
    t.string "replacement_token_registration_code"
    t.index ["login"], name: "index_users_on_login"
  end

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140705130050) do

  create_table "action_roles", :force => true do |t|
    t.integer  "role_id",    :limit => 8
    t.integer  "action_id",  :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", :force => true do |t|
    t.string   "action_name"
    t.integer  "controller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actions", ["action_name"], :name => "index_actions_on_action_name"

  create_table "addresses", :force => true do |t|
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "apt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "floor",      :limit => 8
    t.boolean  "validated",               :default => false
  end

  add_index "addresses", ["address"], :name => "index_addresses_on_address"
  add_index "addresses", ["city"], :name => "index_addresses_on_city"
  add_index "addresses", ["id", "type"], :name => "index_addresses_on_id_and_type"
  add_index "addresses", ["zip"], :name => "index_addresses_on_zip"

  create_table "checkins", :force => true do |t|
    t.integer  "client_id"
    t.integer  "parent_id"
    t.boolean  "id_warn",    :default => false
    t.boolean  "inc_warn",   :default => false
    t.boolean  "res_warn",   :default => false
    t.boolean  "gov_warn",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checkins", ["client_id"], :name => "index_checkins_on_client_id"
  add_index "checkins", ["parent_id"], :name => "index_checkins_on_parent_id"

  create_table "city_zipcodes", :force => true do |t|
    t.string   "zip"
    t.string   "type"
    t.string   "primary_city"
    t.string   "acceptable_cities"
    t.string   "unacceptable_cities"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "client_checkins", :force => true do |t|
    t.integer  "client_id"
    t.boolean  "id_warn",              :default => false
    t.boolean  "primary",              :default => false
    t.integer  "household_checkin_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "clients", :force => true do |t|
    t.integer  "household_id"
    t.string   "firstName"
    t.string   "mi"
    t.string   "lastName"
    t.string   "suffix"
    t.date     "birthdate"
    t.string   "race"
    t.string   "gender"
    t.boolean  "headOfHousehold"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "barcode"
    t.boolean  "veteran",                              :default => false
    t.string   "last_4_ssn",              :limit => 4
    t.date     "ssn_confirmation_date"
    t.integer  "user_id",                 :limit => 8
    t.boolean  "ssi",                                  :default => false
    t.boolean  "medicaid",                             :default => false
    t.boolean  "foodstamps",                           :default => false
    t.boolean  "homeless",                             :default => false
    t.boolean  "disabled",                             :default => false
    t.boolean  "singleParent",                         :default => false
    t.boolean  "vegetarian",                           :default => false
    t.boolean  "diabetic",                             :default => false
    t.boolean  "unemployed",                           :default => false
    t.boolean  "retired",                              :default => false
    t.boolean  "kosher",                               :default => false
    t.boolean  "halal",                                :default => false
    t.boolean  "usda",                                 :default => false
    t.string   "crypted_passport_number"
    t.string   "crypted_alien_id"
    t.string   "alien_id_salt"
    t.string   "passport_number_salt"
    t.boolean  "ssdi",                                 :default => false
  end

  add_index "clients", ["household_id"], :name => "index_clients_on_household_id"
  add_index "clients", ["lastName"], :name => "index_clients_on_lastName"

  create_table "controllers", :force => true do |t|
    t.string   "controller_name"
    t.datetime "last_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controllers", ["controller_name"], :name => "index_controllers_on_controller_name"

  create_table "distributions", :force => true do |t|
    t.integer  "household_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.boolean  "proxy",           :default => false
    t.boolean  "followup",        :default => false
    t.boolean  "sfpp",            :default => false
    t.boolean  "tefap",           :default => false
    t.boolean  "hcpp",            :default => false
    t.boolean  "disaster",        :default => false
    t.text     "proxy_name"
  end

  create_table "household_checkins", :force => true do |t|
    t.integer  "household_id"
    t.boolean  "res_warn",     :default => false
    t.boolean  "inc_warn",     :default => false
    t.boolean  "gov_warn",     :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "households", :force => true do |t|
    t.integer  "perm_address_id"
    t.integer  "temp_address_id"
    t.string   "phone"
    t.string   "email"
    t.integer  "income"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "barcode",                      :limit => 20
    t.integer  "user_id"
    t.boolean  "section8",                                   :default => false
    t.integer  "assigned_pantry_id"
    t.integer  "distributions_count",                        :default => 0,     :null => false
    t.boolean  "tanf",                                       :default => false
    t.integer  "referrer_id",                  :limit => 8
    t.text     "last_distribution_proxy_name"
  end

  create_table "monthly_report_report_months", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "households"
    t.integer  "section8"
    t.integer  "used_before"
    t.integer  "single_person_household"
    t.integer  "adults"
    t.integer  "seniors"
    t.integer  "children"
    t.integer  "veterans"
    t.integer  "disabled"
    t.integer  "clients"
    t.integer  "unique_clients"
    t.integer  "single_parent_household"
    t.integer  "report_wages"
    t.integer  "report_unemployment"
    t.integer  "report_food_stamps"
    t.integer  "report_other_aid"
    t.integer  "report_any_aid"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "notes", :force => true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "phone"
    t.string   "email"
    t.boolean  "active",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "pantry"
    t.boolean  "referrer"
    t.boolean  "verified"
  end

  create_table "pantries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "qualification_documents", :force => true do |t|
    t.string   "type"
    t.integer  "association_id"
    t.boolean  "confirm"
    t.date     "date"
    t.integer  "warnings"
    t.boolean  "vi"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "docfile"
  end

  add_index "qualification_documents", ["association_id", "type"], :name => "index_qualification_documents_on_association_id_and_type"

  create_table "requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.string   "controller", :limit => 25
    t.string   "action",     :limit => 25
    t.string   "params"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "user_id"
    t.string   "session_id"
    t.datetime "login_date"
    t.datetime "logout_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "role_id",    :limit => 8, :null => false
    t.integer  "user_id",    :limit => 8, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "useractions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "action_id"
    t.string   "type"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    t.string   "firstName"
    t.string   "lastName"
    t.string   "type"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pantry_id"
    t.integer  "organization_id"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "validated_addresses", :force => true do |t|
    t.integer  "address_id"
    t.integer  "input_index"
    t.integer  "candidate_index"
    t.string   "delivery_line_1"
    t.string   "last_line"
    t.string   "delivery_point_barcode"
    t.string   "component_primary_number"
    t.string   "component_street_name"
    t.string   "component_street_suffix"
    t.string   "component_city_name"
    t.string   "component_state_abbreviation"
    t.string   "component_zipcode"
    t.string   "component_plus4_code"
    t.string   "component_delivery_point"
    t.string   "component_delivery_point_check_digit"
    t.string   "metadata_record_type"
    t.string   "metadata_zip_type"
    t.string   "metadata_county_fips"
    t.string   "metadata_county_name"
    t.string   "metadata_carrier_route"
    t.string   "metadata_congressional_district"
    t.string   "metadata_rdi"
    t.string   "metadata_elot_sequence"
    t.string   "metadata_elot_sort"
    t.float    "metadata_latitude"
    t.float    "metadata_longitude"
    t.string   "metadata_precision"
    t.string   "metadata_time_zone"
    t.float    "metadata_utc_offset"
    t.boolean  "metadata_dst"
    t.string   "analysis_dpv_match_code"
    t.string   "analysis_dpv_footnotes"
    t.string   "analysis_dpv_cmra"
    t.string   "analysis_dpv_vacant"
    t.string   "analysis_active"
    t.string   "analysis_footnotes"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "validated_addresses", ["address_id"], :name => "index_validated_addresses_on_address_id"
  add_index "validated_addresses", ["id"], :name => "index_validated_addresses_on_id"

end

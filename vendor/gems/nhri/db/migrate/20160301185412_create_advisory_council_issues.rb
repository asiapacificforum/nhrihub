class CreateAdvisoryCouncilIssues < ActiveRecord::Migration
  def change
    create_table :advisory_council_issues do |t|
      t.string   "file_id",               limit: 255
      t.integer  "filesize"
      t.string   "original_filename",     limit: 255
      t.string   "original_type",         limit: 255
      t.integer  "user_id"
      t.string   "title"
      t.integer  "affected_people_count"
      t.float    "violation_coefficient"
      t.integer  "violation_severity_id"
      t.datetime "lastModifiedDate"
      t.text   "article_link"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "issue_areas" do |t|
      t.integer  "advisory_council_issue_id"
      t.integer  "area_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "issue_subareas" do |t|
      t.integer  "advisory_council_issue_id"
      t.integer  "subarea_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

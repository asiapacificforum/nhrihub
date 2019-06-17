class CreateOrganizationsTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table "organizations", force: true do |t|
      t.string   "name"
      t.string   "street"
      t.string   "city"
      t.string   "zip"
      t.string   "phone"
      t.string   "email"
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
    end
  end

  def self.down
    drop_table "organizations"
  end
end

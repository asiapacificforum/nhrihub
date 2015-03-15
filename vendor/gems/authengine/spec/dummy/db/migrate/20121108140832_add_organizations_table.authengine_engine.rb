# This migration comes from authengine_engine (originally 20121107161700)
class AddOrganizationsTable < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :email
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end

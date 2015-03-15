class AddPantryAndReferrerFieldsToOrganizationsTable < ActiveRecord::Migration
  def change
    add_column :organizations, :pantry, :boolean
    add_column :organizations, :referrer, :boolean
  end
end

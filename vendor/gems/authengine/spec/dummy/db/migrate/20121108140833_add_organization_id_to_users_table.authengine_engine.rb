# This migration comes from authengine_engine (originally 20121107162300)
class AddOrganizationIdToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer, :limit => 4
  end
end

# This migration comes from authengine_engine (originally 20110925202800)
class AddTypeFieldToUserRolesTable < ActiveRecord::Migration
  def change
    add_column :user_roles, :type, :string, :default => 'PersistentUserRole'
  end
end

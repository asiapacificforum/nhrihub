# This migration comes from authengine_engine (originally 20130429213400)
class RemoveTypeFieldFromUserRolesTable < ActiveRecord::Migration
  def up
    remove_column :user_roles, :type
  end

  def down
    add_column :user_roles, :type, :string, :default => 'PersistentUserRole'
  end
end

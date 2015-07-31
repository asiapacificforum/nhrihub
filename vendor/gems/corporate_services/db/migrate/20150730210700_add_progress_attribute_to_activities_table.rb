class AddProgressAttributeToActivitiesTable < ActiveRecord::Migration
  def change
    add_column :activities, :progress, :string
  end
end

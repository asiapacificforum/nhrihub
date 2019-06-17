class AddProgressAttributeToActivitiesTable < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :progress, :string
  end
end

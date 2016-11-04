class AddChangeDateToStatusChanges < ActiveRecord::Migration[5.0]
  def change
    add_column :status_changes, :change_date, :datetime
  end
end

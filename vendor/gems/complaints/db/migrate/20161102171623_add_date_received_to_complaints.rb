class AddDateReceivedToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :date_received, :datetime
  end
end

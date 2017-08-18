class ChangeComplaintsDateReceivedToDateType < ActiveRecord::Migration[5.1]
  def self.up
    change_column :complaints, :date_received, :date
  end

  def self.down
    change_column :complaints, :date_received, :datetime
  end
end

class AddGenderToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :gender, :string, :limit => 1
  end
end

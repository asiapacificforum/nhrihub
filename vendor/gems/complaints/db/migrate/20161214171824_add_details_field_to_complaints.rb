class AddDetailsFieldToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :details, :text
  end
end

class RemoveComplaintMandates < ActiveRecord::Migration[5.0]
  def change
    drop_table :complaint_mandates
    add_column :complaints, :mandate_id, :integer
  end
end

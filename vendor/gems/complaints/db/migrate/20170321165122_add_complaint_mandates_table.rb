class AddComplaintMandatesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :complaint_mandates do |t|
      t.integer :complaint_id
      t.integer :mandate_id
      t.timestamps
    end
  end
end

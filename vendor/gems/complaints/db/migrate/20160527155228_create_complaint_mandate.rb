class CreateComplaintMandate < ActiveRecord::Migration
  def change
    create_table :complaint_mandates do |t|
      t.integer :complaint_id
      t.integer :mandate_id
      t.timestamps
    end
  end
end

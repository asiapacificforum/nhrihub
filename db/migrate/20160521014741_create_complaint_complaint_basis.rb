class CreateComplaintComplaintBasis < ActiveRecord::Migration
  def change
    create_table :complaint_complaint_bases do |t|
      t.integer :complaint_id
      t.integer :complaint_basis_id
      t.timestamps
    end
  end
end

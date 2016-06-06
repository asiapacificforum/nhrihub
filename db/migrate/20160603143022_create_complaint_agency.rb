class CreateComplaintAgency < ActiveRecord::Migration
  def change
    create_table :complaint_agencies do |t|
      t.integer :complaint_id
      t.integer :agency_id
      t.timestamps
    end
  end
end

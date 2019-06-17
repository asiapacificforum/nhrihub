class CreateComplaintAgency < ActiveRecord::Migration[4.2]
  def change
    create_table :complaint_agencies, :force => true do |t|
      t.integer :complaint_id
      t.integer :agency_id
      t.timestamps
    end
  end
end

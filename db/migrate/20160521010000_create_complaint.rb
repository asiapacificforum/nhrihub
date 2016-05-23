class CreateComplaint < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :case_reference
      t.string :complainant
      t.string :village
      t.string :phone
      t.boolean :status
      t.string :type
      t.timestamps
    end
  end
end

class CreateComplaint < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :reference
      t.string :complainant
      t.string :village
      t.string :phone
      t.boolean :status
      t.timestamps
    end
  end
end

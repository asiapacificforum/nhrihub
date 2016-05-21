class CreateComplaintBasis < ActiveRecord::Migration
  def change
    create_table :complaint_bases do |t|
      t.string :name
      t.string :type
      t.timestamps
    end
  end
end

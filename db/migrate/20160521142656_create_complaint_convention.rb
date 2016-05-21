class CreateComplaintConvention < ActiveRecord::Migration
  def change
    create_table :complaint_conventions do |t|
      t.integer :complaint_id
      t.integer :convention_id
      t.timestamps
    end
  end
end

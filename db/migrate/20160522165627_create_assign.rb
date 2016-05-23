class CreateAssign < ActiveRecord::Migration
  def change
    create_table :assigns do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.timestamps
    end
  end
end

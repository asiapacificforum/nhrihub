class CreateComplaintMandate < ActiveRecord::Migration[4.2]
  def change
    create_table :complaint_mandates, :force => true do |t|
      t.integer :complaint_id
      t.integer :mandate_id
      t.timestamps
    end
  end
end

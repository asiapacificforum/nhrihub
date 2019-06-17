class CreateComplaintCommunicant < ActiveRecord::Migration[4.2]
  def change
    create_table :communicants, :force => true do |t|
      t.string :name
      t.string :title_key
      t.string :email
      t.string :phone
      t.string :address
      t.integer :organization_id
      t.timestamps
    end

    create_table :communication_communicants, :force => true do |t|
      t.integer :communication_id
      t.integer :communicant_id
      t.timestamps
    end
  end
end

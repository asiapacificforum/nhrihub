class CreateCommunication < ActiveRecord::Migration[4.2]
  def change
    create_table :communications, :force => true do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.string :direction
      t.string :mode
      t.datetime :date
      t.text :note
    end
  end
end

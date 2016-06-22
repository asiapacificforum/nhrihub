class CreateCommunication < ActiveRecord::Migration
  def change
    create_table :communications do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.string :direction
      t.string :mode
      t.datetime :date
      t.text :note
    end
  end
end

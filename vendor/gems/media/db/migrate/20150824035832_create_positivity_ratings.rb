class CreatePositivityRatings < ActiveRecord::Migration[4.2]
  def change
    create_table :positivity_ratings, :force => true do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end
  end
end

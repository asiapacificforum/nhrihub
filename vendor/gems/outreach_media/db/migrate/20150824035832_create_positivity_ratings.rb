class CreatePositivityRatings < ActiveRecord::Migration
  def change
    create_table :positivity_ratings do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end
  end
end

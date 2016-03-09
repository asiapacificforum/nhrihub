class AddNhriIndicatorTables < ActiveRecord::Migration
  def change
    create_table :headings do |t|
      t.string :title
    end

    create_table :offences do |t|
      t.string :description
      t.integer :heading_id
    end

    create_table :indicators do |t|
      t.string :title
      t.integer :offence_id
      t.integer :heading_id
      t.string :nature
      t.string :monitor_text
      t.string :numerical_monitor_method
    end

    create_table :monitors do |t|
      t.integer :indicator_id
      t.date :date
      t.string :description
    end

  end
end

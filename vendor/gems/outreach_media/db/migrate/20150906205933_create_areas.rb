class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.text :name
      t.timestamps
    end


    ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"].each do |a|
      Area.create(:name => a)
    end
  end
end

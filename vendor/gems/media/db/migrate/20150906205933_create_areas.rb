class CreateAreas < ActiveRecord::Migration[4.2]
  def change
    create_table :areas, :force => true do |t|
      t.text :name
      t.timestamps
    end


    ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"].each do |a|
      Area.create(:name => a)
    end
  end
end

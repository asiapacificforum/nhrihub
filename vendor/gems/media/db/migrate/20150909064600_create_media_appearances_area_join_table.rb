class CreateMediaAppearancesAreaJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :media_areas, :force => true do |t|
      t.integer :media_appearance_id
      t.integer :area_id
      t.timestamps
    end

    create_table :media_area_subareas, :force => true do |t|
      t.integer :media_area_id
      t.integer :subarea_id
      t.timestamps
    end
  end
end

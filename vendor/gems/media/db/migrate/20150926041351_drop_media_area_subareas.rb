class DropMediaAreaSubareas < ActiveRecord::Migration[4.2]
  def change
    drop_table :media_area_subareas
  end
end

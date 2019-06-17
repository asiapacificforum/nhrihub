class AddLinkFieldToMediaAppearances < ActiveRecord::Migration[4.2]
  def change
    add_column :media_appearances, :link, :text
  end
end

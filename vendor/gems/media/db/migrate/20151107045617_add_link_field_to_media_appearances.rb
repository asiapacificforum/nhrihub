class AddLinkFieldToMediaAppearances < ActiveRecord::Migration
  def change
    add_column :media_appearances, :link, :text
  end
end

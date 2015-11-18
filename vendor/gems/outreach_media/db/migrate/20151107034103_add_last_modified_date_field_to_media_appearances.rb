class AddLastModifiedDateFieldToMediaAppearances < ActiveRecord::Migration
  def change
    add_column :media_appearances, :lastModifiedDate, :datetime
  end
end

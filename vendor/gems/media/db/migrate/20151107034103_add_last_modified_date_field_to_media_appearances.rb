class AddLastModifiedDateFieldToMediaAppearances < ActiveRecord::Migration[4.2]
  def change
    add_column :media_appearances, :lastModifiedDate, :datetime
  end
end

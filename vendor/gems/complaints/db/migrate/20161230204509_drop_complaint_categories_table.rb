class DropComplaintCategoriesTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :complaint_categories
    drop_table :complaint_complaint_categories
  end
end

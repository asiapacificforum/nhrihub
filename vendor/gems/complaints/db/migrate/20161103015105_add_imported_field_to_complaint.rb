class AddImportedFieldToComplaint < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :imported, :boolean, :default => false
  end
end

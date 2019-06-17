class AddTitleFieldToAccreditationRequiredDocStiTable < ActiveRecord::Migration[4.2]
  def change
    add_column :document_groups, :title, :string
  end
end

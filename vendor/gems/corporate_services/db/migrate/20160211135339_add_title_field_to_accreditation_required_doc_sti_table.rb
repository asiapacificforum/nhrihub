class AddTitleFieldToAccreditationRequiredDocStiTable < ActiveRecord::Migration
  def change
    add_column :document_groups, :title, :string
  end
end

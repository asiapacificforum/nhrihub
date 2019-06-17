class AddStateFieldToOrganizationsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :state, :string
  end
end

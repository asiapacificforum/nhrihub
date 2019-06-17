class AddContactsToOrganizationsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :contacts, :string
  end
end

class AddContactsToOrganizationsTable < ActiveRecord::Migration
  def change
    add_column :organizations, :contacts, :string
  end
end

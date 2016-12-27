class AddComplaintsFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :complaints, :complainant
    add_column :complaints, :firstName, :string
    add_column :complaints, :lastName, :string
    add_column :complaints, :chiefly_title, :string
    add_column :complaints, :occupation, :string
    add_column :complaints, :employer, :string
  end
end

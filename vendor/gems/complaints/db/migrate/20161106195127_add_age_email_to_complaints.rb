class AddAgeEmailToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :age, :integer
    add_column :complaints, :email, :string
  end
end

class ChangeComplaintsAgeToDob < ActiveRecord::Migration[5.0]
  def change
    remove_column :complaints, :age, :integer
    add_column :complaints, :dob, :date
  end
end

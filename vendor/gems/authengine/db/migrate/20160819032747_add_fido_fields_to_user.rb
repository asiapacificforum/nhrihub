class AddFidoFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :challenge, :string
    add_column :users, :challenge_timestamp, :datetime
    add_column :users, :public_key, :string
    add_column :users, :public_key_handle, :string
  end
end

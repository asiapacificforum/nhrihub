class RemoveRememberMeFeature < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :remember_token, :string
    remove_column :users, :remember_token_expires_at, :datetime
  end
end

class AddReplacementTokenRegistrationCodeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :replacement_token_registration_code, :string
  end
end

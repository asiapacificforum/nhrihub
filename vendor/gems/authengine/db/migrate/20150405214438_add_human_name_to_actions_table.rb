class AddHumanNameToActionsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :actions, :human_name, :string
  end
end

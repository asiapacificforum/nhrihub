class AddHumanNameToActionsTable < ActiveRecord::Migration
  def change
    add_column :actions, :human_name, :string
  end
end

# This migration comes from authengine_engine (originally 20111003074700)
class AddIndexesToSeveralTables < ActiveRecord::Migration
  def change
    add_index :actions, :action_name
    add_index :controllers, :controller_name
    add_index :users, :login
  end
end

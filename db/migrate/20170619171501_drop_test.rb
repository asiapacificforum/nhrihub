class DropTest < ActiveRecord::Migration[5.0]
  def up
    if ActiveRecord::Base.connection.table_exists? :test
      drop_table :test
    end
  end

  def down
  end
end

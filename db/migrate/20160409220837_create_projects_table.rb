class CreateProjectsTable < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.text :type
      t.timestamps
    end

    create_table :project_performance_indicators do |t|
      t.integer :project_id
      t.integer :performance_indicator_id
      t.timestamps
    end

    create_table :project_mandates do |t|
      t.integer :project_id
      t.integer :mandate_id
      t.timestamps
    end

    create_table :mandates do |t|
      t.string :key # good_governance, human_rights, special_investigations_unit
      t.timestamps
    end

    create_table :project_project_types do |t|
      t.integer :project_id
      t.integer :project_type_id
      t.timestamps
    end

    create_table :project_types do |t|
      t.string :name
      t.integer :mandate_id
      t.timestamps
    end

    create_table :project_agencies do |t|
      t.integer :project_id
      t.integer :agency_id
      t.timestamps
    end

    create_table :agencies do |t|
      t.string :name
      t.string :full_name
      t.timestamps
    end

    create_table :project_conventions do |t|
      t.integer :project_id
      t.integer :convention_id
      t.timestamps
    end

    create_table :conventions do |t|
      t.string :name
      t.string :full_name
      t.timestamps
    end
  end
end

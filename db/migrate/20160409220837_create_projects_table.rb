class CreateProjectsTable < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.timestamps
    end

    create_table :project_mandates do |t|
      t.integer :project_id
      t.integar :mandate_id
    end

    create_table :mandates do |t|
      t.string :name # Good Governance, Human Rights, Special Investigations Unit
    end

    create_table :project_mandate_types do |t|
      t.integer :project_mandate_id
      t.integar :type_id
    end

    create_table :types do |t|
      t.string :name
      t.timestamps
    end

    create_table :project_agencies do |t|
      t.integer :project_id
      t.integer :agency_id
    end

    create_table :agencies do |t|
      t.string :name
      t.string :full_name
      t.timestamps
    end

    create_table :project_conventions do |t|
      t.integer :project_id
      t.integer :convention_id
    end

    create_table :conventions do |t|
      t.string :name
      t.string :full_name
      t.timestamps
    end
  end
end

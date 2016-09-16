class AddCspReport < ActiveRecord::Migration[5.0]
  def change
    create_table :csp_reports do |t|
      t.string :document_uri,:referrer, :violated_directive, :effective_directive, :source_file
      t.text :original_policy, :blocked_uri
      t.integer :status_code, default: 0
      t.integer :line_number
      t.timestamps
    end
  end
end

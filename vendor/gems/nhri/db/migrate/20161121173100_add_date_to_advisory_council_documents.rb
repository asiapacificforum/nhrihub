class AddDateToAdvisoryCouncilDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :advisory_council_documents, :date, :datetime
  end
end

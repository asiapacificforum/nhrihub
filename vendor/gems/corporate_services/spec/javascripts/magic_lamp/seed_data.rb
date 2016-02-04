require_relative './seed_data/internal_document_seed'
class SeedData
  def self.initialize
    InternalDocumentSeed.populate_test_data
  end
end

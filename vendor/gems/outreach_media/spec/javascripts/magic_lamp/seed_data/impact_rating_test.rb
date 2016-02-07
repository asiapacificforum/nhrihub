class ImpactRatingTest
  def self.populate_test_data
    ImpactRating::DefaultValues.each { |ir| ImpactRating.create(ir.marshal_dump) }
  end
end

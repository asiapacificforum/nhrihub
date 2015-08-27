require 'rspec/core/shared_context'

module MediaSpecHelpers
  extend RSpec::Core::SharedContext

  def setup_positivity_ratings
    PositivityRating.create({:rank => 1, :text => "Reflects very negatively on the office"})
    PositivityRating.create({:rank => 2, :text => "Reflects slightly negatively on the office"})
    PositivityRating.create({:rank => 3, :text => "Has no bearing on the office"})
    PositivityRating.create({:rank => 4, :text => "Reflects slightly positively on the office"})
    PositivityRating.create({:rank => 5, :text => "Reflects very positively on the office"})
  end
end

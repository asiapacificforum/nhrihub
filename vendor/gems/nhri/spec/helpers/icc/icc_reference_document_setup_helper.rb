require 'rspec/core/shared_context'

module IccReferenceDocumentSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database
    reminder = FactoryGirl.create(:reminder,
                                  :reminder_type => 'weekly',
                                  :remindable_type => "IccReferenceDocument",
                                  :text => "don't forget the fruit gums mum",
                                  :user => User.first)
    FactoryGirl.create(:icc_reference_document, :reminders =>[reminder])
  end
end

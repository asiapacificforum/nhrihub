require 'rspec/core/shared_context'

module ComplaintsSpecCommonHelpers
  extend RSpec::Core::SharedContext

  def populate_database(context)
    FactoryGirl.create(:complaint, context, :case_reference => "c12/34", :status => true,
                       :village => Faker::Address.city,
                       :phone => Faker::PhoneNumber.phone_number,
                       :human_rights_complaint_bases => human_rights_complaint_bases,
                       :good_governance_complaint_bases => good_governance_complaint_bases,
                       :siu_complaint_bases => siu_complaint_bases,
                       :assigns => assigns,
                       :complaint_documents => complaint_docs)
  end

  private

  def complaint_docs
    Array.new(2) { FactoryGirl.create(:complaint_document) }
  end

  def human_rights_complaint_bases
    Array.new(2) { FactoryGirl.create(:convention) }
  end

  def good_governance_complaint_bases
    names = GoodGovernance::ComplaintBasis::DefaultNames.sample(2)
    names.collect{|name| FactoryGirl.create(:good_governance_complaint_basis, :name => name) }
  end

  def siu_complaint_bases
    names = Siu::ComplaintBasis::DefaultNames.sample(2)
    names.collect{|name| FactoryGirl.create(:siu_complaint_basis, :name => name) }
  end

  def assigns
    Array.new(2) do
      assignee = FactoryGirl.create(:assignee, :with_password)
      date = DateTime.now.advance(:days => -rand(365))
      Assign.new(:created_at => date, :assignee => assignee)
    end
  end

end

require 'rspec/core/shared_context'

module ComplaintsSpecSetupHelpers
  extend RSpec::Core::SharedContext

  def populate_database
    FactoryGirl.create(:complaint, :case_reference => "c12/34", :status => true,
                       :village => Faker::Address.city,
                       :phone => Faker::PhoneNumber.phone_number,
                       :human_rights_complaint_bases => hr_complaint_bases,
                       :good_governance_complaint_bases => gg_complaint_bases,
                       :special_investigations_unit_complaint_bases => siu_complaint_bases,
                       :assigns => assigns,
                       :complaint_documents => complaint_docs,
                       :complaint_categories => complaint_cats)
    [:good_governance, :human_rights, :special_investigations_unit].each do |key|
      FactoryGirl.create(:mandate, :key => key)
    end
  end

  private

  def complaint_cats
    Array.new(1) { FactoryGirl.create(:complaint_category) }
  end

  def complaint_docs
    Array.new(2) { FactoryGirl.create(:complaint_document) }
  end

  def hr_complaint_bases
    names = ["CAT", "ICESCR"]
    names.collect{|name| FactoryGirl.create(:convention, :name => name)}
  end

  def gg_complaint_bases
    names = ["Delayed action", "Failure to act"]
    names.collect{|name| FactoryGirl.create(:good_governance_complaint_basis, :name => name) }
  end

  def siu_complaint_bases
    names = ["Unreasonable delay", "Not properly investigated"]
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

require 'rspec/core/shared_context'

module OrganizationPresetsHelper
  extend RSpec::Core::SharedContext
  before do
    @organization_with_no_users = Organization.create(:name => "Government of Illyria",
                                                      :street => "38 Powis Square",
                                                      :city => "Notting Hill",
                                                      :state => "Amnesia",
                                                      :zip => "12345",
                                                      :contacts => ContactList.new([Contact.new(:phone => '862-385-1818'),
                                                                                 Contact.new(:phone => '489-733-4829')]),
                                                      :email => "kahuna@bigbrother.gov")
    @organization_with_users = Organization.create(:name => "Government of Maldonia")
    FactoryGirl.create(:user, :organization => @arganization_with_users)
  end
end


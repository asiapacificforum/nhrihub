class CorporateServices::ComplaintBasis < ComplaintBasis
  has_many :complaint_corporate_services_complaint_bases
  include NamedList
  # included as a reference, and as source for complaint_basis_factory.rb
  # actual names are user-configured via admin
  DefaultNames = []
  validates :name, :uniqueness => true

  def self.i18n_key
    :corporate_services
  end
end

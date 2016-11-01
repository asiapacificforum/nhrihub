class GoodGovernance::ComplaintBasis < ComplaintBasis
  has_many :complaint_good_governance_complaint_bases
  include NamedList
  # included as a reference, and as source for complaint_basis_factory.rb
  # actual names are user-configured via admin
  DefaultNames = ["Private", "Unreasonable", "Unjust", "Failure to act", "Delayed action"]
  validates :name, :uniqueness => true

  def self.i18n_key
    :good_governance
  end
end

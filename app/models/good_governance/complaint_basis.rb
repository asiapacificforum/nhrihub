class GoodGovernance::ComplaintBasis < ComplaintBasis
  # included as a reference, and as source for complaint_basis_factory.rb
  # actual names are user-configured via admin
  DefaultNames = ["Private", "Unreasonable", "Unjust", "Failure to act", "Delayed action"]
  validates :name, :uniqueness => true
end

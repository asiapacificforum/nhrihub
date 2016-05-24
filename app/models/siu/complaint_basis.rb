class Siu::ComplaintBasis < ComplaintBasis
  # included as a reference, and as source for complaint_basis_factory.rb
  # actual names are user-configured via admin
  DefaultNames = ["Unreasonable delay", "Abuse of process", "Not properly investigated"]
  validates :name, :uniqueness => true
end

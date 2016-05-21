class GoodGovernance::ComplaintBasis < ComplaintBasis
  validates :name, :uniqueness => true
end

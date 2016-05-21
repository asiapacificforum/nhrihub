class Siu::ComplaintBasis < ComplaintBasis
  validates :name, :uniqueness => true
end

class GoodGovernance::DocumentGroup < DocumentGroup
  has_many :internal_documents, :class_name => "GoodGovernance::InternalDocument", :dependent => :destroy
end

class CorporateServices::DocumentGroup < DocumentGroup
  has_many :internal_documents, :class_name => "CorporateServices::InternalDocument", :dependent => :destroy
end

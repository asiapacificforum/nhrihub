class Nhri::ProtectionPromotion::DocumentGroup < DocumentGroup
  has_many :internal_documents, :class_name => "Nhri::ProtectionPromotion::InternalDocument", :dependent => :destroy
end


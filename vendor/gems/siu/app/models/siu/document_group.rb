class Siu::DocumentGroup < DocumentGroup
  has_many :internal_documents, :class_name => "Siu::InternalDocument", :dependent => :destroy
end

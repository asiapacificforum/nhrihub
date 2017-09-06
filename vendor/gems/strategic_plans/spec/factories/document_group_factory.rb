FactoryGirl.define do
  factory :document_group do
  end
  factory :accreditation_document_group, :parent => :document_group, :class => AccreditationDocumentGroup do
  end
end

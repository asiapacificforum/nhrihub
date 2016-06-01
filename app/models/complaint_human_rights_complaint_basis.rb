class ComplaintHumanRightsComplaintBasis < ComplaintComplaintBasis
  belongs_to :human_rights_complaint_basis, :class_name => 'Convention', :foreign_key => :complaint_basis_id
end

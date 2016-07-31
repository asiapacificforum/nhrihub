class ComplaintSpecialInvestigationsUnitComplaintBasis < ComplaintComplaintBasis
  belongs_to :special_investigations_unit_complaint_basis, :class_name => 'Siu::ComplaintBasis', :foreign_key => :complaint_basis_id
end

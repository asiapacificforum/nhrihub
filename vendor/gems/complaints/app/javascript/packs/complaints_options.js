/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const complaints_options = {
  el : '#complaints',
  template : '#complaints_template',
  data() {
    return $.extend(true,{},complaints_page_data());
  },
  oninit() {
    return this.set({
      'expanded' : false});
  },
  components : {
    complaint : Complaint,
    filterControls : FilterControls
  },
  computed : {
    selected_agency_ids() { return this.findComponent('filterControls').get('agency_ids'); }
  },
  new_complaint() {
    if (!this.add_complaint_active()) {
      const new_complaint = {
        assigns : [],
        case_reference : this.get('next_case_reference'),
        firstName : "",
        lastName : "",
        attached_documents : [],
        current_assignee : "",
        current_assignee_id : "",
        new_assignee_id : null,
        formatted_date : "",
        good_governance_complaint_basis_ids : [],
        human_rights_complaint_basis_ids : [],
        special_investigations_unit_complaint_basis_ids : [],
        id : null,
        mandate_ids : [],
        agency_ids : [],
        notes : [],
        phone : "",
        reminders : [],
        current_status_humanized : "Under Evaluation",
        village : "",
        complained_to_subject_agency : false,
        date_received : null,
        dob : null,
        date_of_birth : null
      };
      UserInput.claim_user_input_request(this,'cancel_add_complaint');
      return this.unshift('complaints',new_complaint);
    }
  },
  cancel_add_complaint() {
    const new_complaint = _(this.findAllComponents('complaint')).find(complaint=> !complaint.get('persisted'));
    return this.remove(new_complaint._guid);
  },
  remove(guid){
    const complaint_guids = _(this.findAllComponents('complaint')).map(complaint=> complaint._guid);
    const index = complaint_guids.indexOf(guid);
    return this.splice('complaints',index,1);
  },
  add_complaint_active() {
    return !_.isEmpty(this.findAllComponents('complaint')) && !this.findAllComponents('complaint')[0].get('persisted');
  },
  set_filter_criteria_from_date(selectedDate){
    return this.set('filter_criteria.from',selectedDate);
  },
  set_filter_criteria_to_date(selectedDate){
    return this.set('filter_criteria.to',selectedDate);
  },
  expand() {
    this.set('expanded', true);
    return _(this.findAllComponents('complaint')).each(ma=> ma.expand());
  },
  compact() {
    this.set('expanded', false);
    return _(this.findAllComponents('complaint')).each(ma=> ma.compact());
  },
  generate_report() {
    return window.location=Routes.complaints_path('en',{format : 'docx'});
  },
  increment_next_case_reference(last_ref){
    const ref_components = last_ref.split('-');
    const new_ref = `${ref_components[0]}-${parseInt(ref_components[1])+1}`;
    return this.set('next_case_reference', new_ref);
  }
};

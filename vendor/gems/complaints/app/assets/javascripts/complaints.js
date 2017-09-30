//= require 'in_page_edit'
//= require 'ractive_validator'
//= require 'file_input_decorator'
//= require 'progress_bar'
//= require 'ractive_local_methods'
//= require 'string'
//= require 'jquery_datepicker'
//= require 'filter_criteria_datepicker'
//= require 'confirm_delete_modal'
//= require 'attached_documents'
//= require 'communication'
//= require 'notable'
//= require 'remindable'

this.documents = new Ractive({
  el : '#documents',
  template : '#documents_modal_template',
  components : {
    attachedDocuments : AttachedDocuments
  },
  showModal() {
    return $(this.find('#documents_modal')).modal('show');
  }
});

const EditInPlace = function(node,id){
  const ractive = this;
  const edit = new InpageEdit({
    object : this,
    on : node,
    focus_element : 'input.title',
    success(response, textStatus, jqXhr){
      this.options.object.set(response);
      return this.load();
    },
    error() {
      return console.log("Changes were not saved, for some reason");
    },
    start_callback : () => {
      this.set('new_assignee_id',undefined);
      return ractive.expand();
    }
  });
  return {
    teardown : id=> {
      return edit.off();
    },
    update : id=> {}
    };
};

//const AgenciesSelector = Ractive.extend({
  //template : '#agencies_selector_template'});

const Agency = Ractive.extend({
  template : '#agency_template',
  computed : {
    name() {
      const agency = _(window.complaints_page_data().all_agencies).findWhere({id : this.get('id')});
      if (_.isUndefined(agency)) { return null; } else { return agency.name; }
    }
  }
});

const Agencies = Ractive.extend({
  template : '#agencies_template',
  components : {
    agency : Agency
  }
});

const MandatesSelector = Ractive.extend({
  template : '#mandates_selector_template',
  remove_error() {
    if (this.parent.get('mandate_id_count') !== 0) {
      return this.parent.remove_attribute_error('mandate_id_count');
    }
  }
});

const ComplaintBasesSelector = Ractive.extend({
  template : '#complaint_bases_selector_template',
  remove_error() {
    if (this.parent.get('complaint_basis_id_count') !== 0) {
      return this.parent.remove_attribute_error('complaint_basis_id_count');
    }
  }
});

const Assignee = Ractive.extend({
  template : "#assignee_template"});

const Assignees = Ractive.extend({
  template : "#assignees_template",
  components : {
    assignee : Assignee
  }
});

const ComplaintBasis = Ractive.extend({
  template : '#complaint_basis_template',
  computed : {
    name() {
      var mandate = _(window.source_complaint_bases).find(cb=> _.isEqual(cb.key, this.get(mandate).mandate));
      if (_.isUndefined(mandate)) {
        return null;
      } else {
        const complaint_basis = _(mandate.complaint_bases).find(cb=> _.isEqual(cb.id, this.get('id')));
        return complaint_basis.name;
      }
    }
  }
});

const ComplaintBases = Ractive.extend({
  template : '#complaint_bases_template',
  components : {
    complaintBasis : ComplaintBasis
  }
});

const AssigneeSelector = Ractive.extend({
  template : '#assignee_selector_template',
  remove_error() {
    return this.parent.remove_attribute_error('new_assignee_id');
  }
});

const EditBackup = {
  stash() {
    const stashed_attributes = _(this.get()).pick(this.get('persistent_attributes'));
    return this.stashed_instance = $.extend(true,{},stashed_attributes);
  },
  restore() {
    return this.set(this.stashed_instance);
  }
};

const Mandate = Ractive.extend({
  template : '#mandate_template',
  computed : {
    name() {
      const mandate = _(this.get('all_mandates')).findWhere({id : this.get('id')});
      return mandate.name;
    }
  }
});

const Mandates = Ractive.extend({
  template : '#mandates_template',
  components : {
    mandate : Mandate
  }
});

const Persistence = {
  delete_callback(data,textStatus,jqxhr){
    return this.parent.remove(this._guid);
  },
  save_complaint() {
    if (this.validate()) {
      const data = this.formData();
      return $.ajax({
        // thanks to http://stackoverflow.com/a/22987941/451893
        //xhr: @progress_bar_create.bind(@)
        method : 'post',
        data,
        url : Routes.complaints_path(current_locale),
        success : this.save_complaint_callback,
        context : this,
        processData : false,
        contentType : false
      });
    }
  }, // jQuery correctly sets the contentType and boundary values
  formData() {
    return this.asFormData(this.get('persistent_attributes'));
  }, // in ractive_local_methods, returns a FormData instance
  save_complaint_callback(response, status, jqxhr){
    UserInput.reset();
    this.set(response);
    return complaints.increment_next_case_reference(response.case_reference);
  },
  progress_bar_create() {
    return this.findComponent('progressBar').start();
  },
  update_persist(success, error, context) { // called by EditInPlace
    if (this.validate()) {
      const data = this.formData();
      return $.ajax({
        // thanks to http://stackoverflow.com/a/22987941/451893
        //xhr: @progress_bar_create.bind(@)
        method : 'put',
        data,
        url : this.get('persisted') ? Routes.complaint_path(current_locale, this.get('id')) : undefined,
        success,
        context,
        processData : false,
        contentType : false
      });
    }
  } // jQuery correctly sets the contentType and boundary values
};

const ComplaintDocuments = AttachedDocuments.extend({
  oninit() {
    return this.set({
      parent_type : 'complaint',
      parent_named_document_datalist : this.get('complaint_named_document_titles')
    });
  }
});

const FilterMatch = {
  include() {
    //console.log "call include()"
    // console.log JSON.stringify "matches_complainant" : @matches_complainant(), "matches_case_reference" : @matches_case_reference(), "matches_village" : @matches_village(), "matches_date" : @matches_date(), "matches_phone" : @matches_phone(), "matches_agencies" : @matches_agencies(), "matches_assignee" : @matches_assignee(), "matches_status" : @matches_status(), "matches_basis" : @matches_basis
    // console.log JSON.stringify "matches_good_governance_complaint_basis" : @matches_good_governance_complaint_basis(), "matches_human_rights_complaint_basis" : @matches_human_rights_complaint_basis(), "matches_special_investigations_unit_complaint_basis" : @matches_special_investigations_unit_complaint_basis(), "basis_rule" : @get('filter_criteria.basis_rule'), "matches_basis" : @matches_basis(), "basis_requirement_is_specified" : @basis_requirement_is_specified(), "good_governance_basis_requirement_is_specified" : @good_governance_basis_requirement_is_specified(), "human_rights_basis_requirement_is_specified" : @human_rights_basis_requirement_is_specified(), "special_investigations_unit_basis_requirement_is_specified" : @special_investigations_unit_basis_requirement_is_specified()
    // console.log JSON.stringify "matches_area" : @matches_area()
    return this.matches_complainant() &&
    this.matches_case_reference() &&
    this.matches_village() &&
    this.matches_date() &&
    this.matches_phone() &&
    this.matches_agencies() &&
    this.matches_basis() &&
    this.matches_assignee() &&
    this.matches_status() &&
    this.matches_area();
  },
  matches_area() {
    if (!_.isNumber(this.get('filter_criteria.mandate_id')) || _.isNull(this.get('filter_criteria.mandate_id'))) { return true; }
    return parseInt(this.get('mandate_id')) === parseInt(this.get('filter_criteria.mandate_id'));
  },
  matches_complainant() {
    if (_.isEmpty(this.get('filter_criteria.complainant'))) { return true; }
    const flexible_space_match = this.get('filter_criteria.complainant').trim().replace(/\s+/g, "\\s+");
    const re = new RegExp(flexible_space_match,"i");
    const full_name = [this.get('chiefly_title'),this.get('firstName'),this.get('lastName')].join(' ');
    return re.test(full_name);
  },
  matches_case_reference() {
    if (_.isEmpty(this.get('filter_criteria.case_reference'))) { return true; }
    const criterion_digits = this.get('filter_criteria.case_reference').replace(/\D/g,'');
    const value_digits = this.get('case_reference').replace(/\D/g,'');
    const re = new RegExp(criterion_digits);
    return re.test(value_digits);
  },
  matches_village() {
    if (_.isEmpty(this.get('filter_criteria.village'))) { return true; }
    const re = new RegExp(this.get('filter_criteria.village').trim(),"i");
    return re.test(this.get('village'));
  },
  matches_date() {
    return this.matches_from() && this.matches_to();
  },
  matches_from() {
    if (_.isNull(this.get('date')) || _.isEmpty(this.get('filter_criteria.from'))) { return true; }
    return (new Date(this.get('date'))).valueOf() >= Date.parse(this.get('filter_criteria.from'));
  },
  matches_to() {
    if (_.isNull(this.get('date')) || _.isEmpty(this.get('filter_criteria.to'))) { return true; }
    return (new Date(this.get('date'))).valueOf() <= Date.parse(this.get('filter_criteria.to'));
  },
  matches_phone() {
    if (_.isEmpty(this.get('filter_criteria.phone'))) { return true; }
    const criterion_digits = this.get('filter_criteria.phone').replace(/\D/g,'');
    const value_digits = this.get('phone').replace(/\D/g,'');
    const re = new RegExp(criterion_digits);
    return re.test(value_digits);
  },
  matches_agencies() {
    if (_.isEmpty(this.get('filter_criteria.selected_agency_ids'))) { return true; }
    return _.intersection(this.get('filter_criteria.selected_agency_ids'), this.get('agency_ids')).length > 0;
  },
  matches_basis() {
    const match = this.matches_good_governance_complaint_basis() || // each val is undefined if no ids were selected
            this.matches_human_rights_complaint_basis() || // if all of them are undefined, match is undefined
            this.matches_special_investigations_unit_complaint_basis(); // if any is true, true is returned
    if (_.isUndefined(match)) { return true; }
    if (!this.basis_requirement_is_specified()) {
      return true;
    } else {
      return match;
    }
  },
  basis_requirement_is_specified() {
    return this.good_governance_basis_requirement_is_specified() ||
    this.human_rights_basis_requirement_is_specified() ||
    this.special_investigations_unit_basis_requirement_is_specified();
  },
  good_governance_basis_requirement_is_specified() {
    const selected = this.get('filter_criteria.selected_good_governance_complaint_basis_ids');
    return !(_.isEmpty(selected) || _.isUndefined(selected));
  },
  human_rights_basis_requirement_is_specified() {
    const selected = this.get('filter_criteria.selected_human_rights_complaint_basis_ids');
    return !(_.isEmpty(selected) || _.isUndefined(selected));
  },
  special_investigations_unit_basis_requirement_is_specified() {
    const selected = this.get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids');
    return !(_.isEmpty(selected) || _.isUndefined(selected));
  },
  matches_good_governance_complaint_basis() {
    const selected = this.get('filter_criteria.selected_good_governance_complaint_basis_ids');
    const attrs = this.get('good_governance_complaint_basis_ids');
    return _.intersection(selected,attrs).length > 0;
  },
  matches_human_rights_complaint_basis() {
    const selected = this.get('filter_criteria.selected_human_rights_complaint_basis_ids');
    const attrs = this.get('human_rights_complaint_basis_ids');
    return _.intersection(selected,attrs).length > 0;
  },
  matches_special_investigations_unit_complaint_basis() {
    const selected = this.get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids');
    const attrs = this.get('special_investigations_unit_complaint_basis_ids');
    return _.intersection(selected,attrs).length > 0;
  },
  matches_assignee() {
    const selected_assignee_id = this.get('filter_criteria.selected_assignee_id');
    const assignee_id = this.get('current_assignee_id');
    return _.isNaN(parseInt(selected_assignee_id)) || (assignee_id === selected_assignee_id);
  },
  matches_status() {
    const selected_statuses = this.get('filter_criteria.selected_statuses');
    const status_name = this.get('current_status_humanized');
    return _.isEmpty(selected_statuses) || (selected_statuses.indexOf(status_name) !== -1);
  }
};

const Toggle = {
  oninit() {
    return this.set('selected',false);
  },
  toggle() {
    this.event.original.preventDefault();
    this.event.original.stopPropagation();
    return this.set('selected',!this.get('selected'));
  }
};

import GoodGovernanceComplaintBasisFilterSelect from '../good_governance_complaint_basis_filter_select'
import HumanRightsComplaintBasisFilterSelect from '../human_rights_complaint_basis_filter_select'
import SpecialInvestigationsUnitComplaintBasisFilterSelect from '../special_investigations_unit_complaint_basis_filter_select'
import AgencyFilterSelect from '../agency_filter_select'
import AssigneeFilterSelect from '../assignee_filter_select'
import MandateFilterSelect from '../mandate_filter_select'
import StatusSelector from '../status_selector'

const FilterControls = Ractive.extend({
  template : "#filter_controls_template",
  components : {
    goodGovernanceComplaintBasisFilterSelect : GoodGovernanceComplaintBasisFilterSelect,
    humanRightsComplaintBasisFilterSelect : HumanRightsComplaintBasisFilterSelect,
    specialInvestigationsUnitComplaintBasisFilterSelect : SpecialInvestigationsUnitComplaintBasisFilterSelect,
    agencyFilterSelect : AgencyFilterSelect,
    mandateFilterSelect : MandateFilterSelect,
    assigneeFilterSelect : AssigneeFilterSelect,
    statusSelector : StatusSelector
  },
  expand() {
    return this.parent.expand();
  },
  compact() {
    return this.parent.compact();
  },
  clear_filter() {
    this.set('filter_criteria',$.extend(true,{},complaints_page_data().filter_criteria));
    window.history.pushState({foo: "bar"},"unused title string",window.location.origin + window.location.pathname);
    return this.set_filter_from_query_string();
  },
  set_filter_from_query_string() {
    const search_string = (_.isEmpty( window.location.search) || _.isNull( window.location.search)) ? '' : window.location.search.split("=")[1];
    const filter_criteria = _.extend(source_filter_criteria,{case_reference : search_string});
    return this.set('filter_criteria',filter_criteria);
  }
});

window.complaints_page_data = () =>
  ({
    complaints : source_complaints_data,
    all_mandates : source_all_mandates,
    complaint_bases : source_complaint_bases,
    all_agencies : source_all_agencies,
    all_agencies_in_sixes : source_all_agencies_in_sixes,
    all_users : source_all_users,
    filter_criteria : source_filter_criteria,
    all_good_governance_complaint_bases : source_all_good_governance_complaint_bases,
    all_human_rights_complaint_bases : source_all_human_rights_complaint_bases,
    all_special_investigations_unit_complaint_bases : source_all_special_investigations_unit_complaint_bases,
    all_staff : source_all_staff,
    permitted_filetypes : source_permitted_filetypes,
    maximum_filesize : source_maximum_filesize,
    communication_permitted_filetypes : source_communication_permitted_filetypes,
    communication_maximum_filesize : source_communication_maximum_filesize,
    statuses : source_statuses,
    next_case_reference : source_next_case_reference
  })
;

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

window.start_page = () => window.complaints = new Ractive(complaints_options);

Ractive.decorators.inpage_edit = EditInPlace;

Ractive.prototype.local = gmt_date=> $.datepicker.formatDate("M d, yy", new Date(gmt_date));

$(function() {
  start_page();
  filter_criteria_datepicker.start(complaints);
  // so that a state object is present when returnng to the initial state with the back button
  // this is so we can discriminate returning to the page from page load
  return history.replaceState({bish:"bosh"},"bash",window.location);
});

window.onpopstate = function(event){
  if (event.state) { // to ensure that it doesn't trigger on page load, it's a problem with phantomjs but not with chrome
    return window.complaints.findComponent('filterControls').set_filter_from_query_string();
  }
};

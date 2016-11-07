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


EditInPlace = (node,id)->
  ractive = @
  edit = new InpageEdit
    object : @
    on : node
    focus_element : 'input.title'
    success : (response, textStatus, jqXhr)->
      @.options.object.set(response)
      @load()
    error : ->
      console.log "Changes were not saved, for some reason"
    start_callback : -> ractive.expand()
  return {
    teardown : (id)=>
      edit.off()
    update : (id)=>
    }

AgenciesSelector = Ractive.extend
  template : '#agencies_selector_template'

Agency = Ractive.extend
  template : '#agency_template'
  computed :
    name : ->
      agency = _(@get('all_agencies')).findWhere(id : @get('id'))
      agency.name

Agencies = Ractive.extend
  template : '#agencies_template'
  components :
    agency : Agency

MandatesSelector = Ractive.extend
  template : '#mandates_selector_template'
  remove_error : ->
    if !_.isEmpty @get('mandate_name')
      @parent.remove_attribute_error('mandate_name')

ComplaintBasesSelector = Ractive.extend
  template : '#complaint_bases_selector_template'
  remove_error : ->
    if @parent.get('complaint_basis_id_count') != 0
      @parent.remove_attribute_error('complaint_basis_id_count')

Assignee = Ractive.extend
  template : "#assignee_template"

Assignees = Ractive.extend
  template : "#assignees_template"
  components :
    assignee : Assignee

ComplaintBasis = Ractive.extend
  template : '#complaint_basis_template'
  computed :
    name : ->
      mandate = _(@get('complaint_bases')).find (cb)=> _.isEqual(cb.key, @get(mandate).mandate)
      complaint_basis = _(mandate.complaint_bases).find (cb)=> _.isEqual(cb.id, @get('id'))
      complaint_basis.name

ComplaintBases = Ractive.extend
  template : '#complaint_bases_template'
  components :
    complaintBasis : ComplaintBasis

ComplaintCategory = Ractive.extend
  template : '#complaint_category_template'

ComplaintCategories = Ractive.extend
  template : '#complaint_categories_template'
  components :
    complaintCategory : ComplaintCategory

AssigneeSelector = Ractive.extend
  template : '#assignee_selector_template'
  remove_error : ->
    @parent.remove_attribute_error('new_assignee_id')

EditBackup =
  stash : ->
    stashed_attributes = _(@get()).pick(@get('persistent_attributes'))
    @stashed_instance = $.extend(true,{},stashed_attributes)
  restore : ->
    @set(@stashed_instance)
    @restore_checkboxes()
    @restore_radio_checkboxes()
  restore_checkboxes : ->
    # major hack to circumvent ractive bug,
    # it will not be necessary in ractive 0.8.0
    _(['good_governance_complaint_basis','human_rights_complaint_basis','special_investigations_unit_complaint_basis', 'agency']).
      each (association)=>
        @restore_checkboxes_for(association)
  restore_checkboxes_for : (association)->
    ids = @get("#{association}_ids")
    _(@findAll(".edit .#{association} input")).each (checkbox)->
      is_checked = ids.indexOf(parseInt($(checkbox).attr('value'))) != -1
      $(checkbox).prop('checked',is_checked)
  restore_radio_checkboxes : ->
    selected_mandate = @get('mandate_name')
    $("input:radio[value='#{selected_mandate}']",@find('*')).prop('checked',true)

Mandate = Ractive.extend
  template : '#mandate_template'
  computed :
    name : ->
      mandate = _(@get('all_mandates')).findWhere(id : @get('id'))
      mandate.name

Mandates = Ractive.extend
  template : '#mandates_template'
  components :
    mandate : Mandate

ComplaintCategoriesSelector = Ractive.extend
  template : '#complaint_categories_selector'

Persistence = $.extend
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  save_complaint: ->
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
        method : 'post'
        data : data
        url : Routes.complaints_path(current_locale)
        success : @save_complaint_callback
        context : @
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  formData : ->
    @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
  save_complaint_callback : (response, status, jqxhr)->
    UserInput.reset()
    @set(response)
  progress_bar_create : ->
    @findComponent('progressBar').start()
  update_persist : (success, error, context) -> # called by EditInPlace
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
        method : 'put'
        data : data
        url : Routes.complaint_path(current_locale, @get('id'))
        success : success
        context : context
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  , ConfirmDeleteModal

ComplaintDocuments = Ractive.extend
  oninit : ->
    @set
      parent_type : 'complaint'
      parent_named_document_datalist : @get('complaint_named_document_titles')
  , AttachedDocuments

FilterMatch =
  include : ->
    #console.log JSON.stringify "matches_complainant" : @matches_complainant(), "matches_case_reference" : @matches_case_reference(), "matches_village" : @matches_village(), "matches_date" : @matches_date(), "matches_phone" : @matches_phone(), "matches_agencies" : @matches_agencies(), "matches_assignee" : @matches_assignee(), "matches_status" : @matches_status(), "matches_basis" : @matches_basis
    #console.log JSON.stringify "matches_good_governance_complaint_basis" : @matches_good_governance_complaint_basis(), "matches_human_rights_complaint_basis" : @matches_human_rights_complaint_basis(), "matches_special_investigations_unit_complaint_basis" : @matches_special_investigations_unit_complaint_basis(), "basis_rule" : @get('filter_criteria.basis_rule'), "matches_basis" : @matches_basis(), "basis_requirement_is_specified" : @basis_requirement_is_specified(), "good_governance_basis_requirement_is_specified" : @good_governance_basis_requirement_is_specified(), "human_rights_basis_requirement_is_specified" : @human_rights_basis_requirement_is_specified(), "special_investigations_unit_basis_requirement_is_specified" : @special_investigations_unit_basis_requirement_is_specified()
    @matches_complainant() &&
    @matches_case_reference() &&
    @matches_village() &&
    @matches_date() &&
    @matches_phone() &&
    @matches_agencies() &&
    @matches_basis() &&
    @matches_assignee() &&
    @matches_status()
  matches_complainant : ->
    return true if _.isEmpty(@get('filter_criteria.complainant'))
    re = new RegExp(@get('filter_criteria.complainant').trim(),"i")
    re.test @get('complainant')
  matches_case_reference : ->
    return true if _.isEmpty(@get('filter_criteria.case_reference'))
    criterion_digits = @get('filter_criteria.case_reference').replace(/\D/g,'')
    value_digits = @get('case_reference').replace(/\D/g,'')
    re = new RegExp(criterion_digits)
    re.test value_digits
  matches_village : ->
    return true if _.isEmpty(@get('filter_criteria.village'))
    re = new RegExp(@get('filter_criteria.village').trim(),"i")
    re.test @get('village')
  matches_date : ->
    @matches_from() && @matches_to()
  matches_from : ->
    return true if _.isNull(@get('date')) || _.isEmpty(@get('filter_criteria.from'))
    (new Date(@get('date'))).valueOf() >= Date.parse(@get('filter_criteria.from'))
  matches_to : ->
    return true if _.isNull(@get('date')) || _.isEmpty(@get('filter_criteria.to'))
    (new Date(@get('date'))).valueOf() <= Date.parse(@get('filter_criteria.to'))
  matches_phone : ->
    return true if _.isEmpty(@get('filter_criteria.phone'))
    criterion_digits = @get('filter_criteria.phone').replace(/\D/g,'')
    value_digits = @get('phone').replace(/\D/g,'')
    re = new RegExp(criterion_digits)
    re.test value_digits
  matches_agencies : ->
    return true if _.isEmpty(@get('filter_criteria.selected_agency_ids')) || _.isNull(@get('filter_criteria.agency_rule'))
    if @get('filter_criteria.agency_rule') is 'all'
      _.isEqual(@get('filter_criteria.selected_agency_ids').slice().sort(), @get('agency_ids').slice().sort())
    else if @get('filter_criteria.agency_rule') is 'any'
      _.intersection(@get('filter_criteria.selected_agency_ids'), @get('agency_ids')).length > 0
  matches_basis : ->
    if @get('filter_criteria.basis_rule') == 'all'
      !@basis_requirement_is_specified() ||
      ( @matches_good_governance_complaint_basis() &&
        @matches_human_rights_complaint_basis() &&
        @matches_special_investigations_unit_complaint_basis())
    else if @get('filter_criteria.basis_rule') == 'any'
      match = @matches_good_governance_complaint_basis() || # each val is undefined if no ids were selected
              @matches_human_rights_complaint_basis() || # if all of them are undefined, match is undefined
              @matches_special_investigations_unit_complaint_basis() # if any is true, true is returned
      return true if _.isUndefined(match)
      match
    else
      true # declare a match, b/c no requirements are specified
  basis_requirement_is_specified : ->
    @good_governance_basis_requirement_is_specified() ||
    @human_rights_basis_requirement_is_specified() ||
    @special_investigations_unit_basis_requirement_is_specified()
  good_governance_basis_requirement_is_specified : ->
    selected = @get('filter_criteria.selected_good_governance_complaint_basis_ids')
    !(_.isEmpty(selected) || _.isUndefined(selected))
  human_rights_basis_requirement_is_specified : ->
    selected = @get('filter_criteria.selected_human_rights_complaint_basis_ids')
    !(_.isEmpty(selected) || _.isUndefined(selected))
  special_investigations_unit_basis_requirement_is_specified : ->
    selected = @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids')
    !(_.isEmpty(selected) || _.isUndefined(selected))
  matches_good_governance_complaint_basis : ->
    selected = @get('filter_criteria.selected_good_governance_complaint_basis_ids')
    attrs = @get('good_governance_complaint_basis_ids')
    if @get('filter_criteria.basis_rule') is 'all'
      common_elements = _.intersection(selected,attrs)
      _.isEqual(common_elements.length,selected.length)
    else if (@get('filter_criteria.basis_rule') is 'any')
      _.intersection(selected,attrs).length > 0
  matches_human_rights_complaint_basis : ->
    selected = @get('filter_criteria.selected_human_rights_complaint_basis_ids')
    attrs = @get('human_rights_complaint_basis_ids')
    if @get('filter_criteria.basis_rule') is 'all'
      common_elements = _.intersection(selected,attrs)
      _.isEqual(common_elements.length,selected.length)
    else if (@get('filter_criteria.basis_rule') is 'any')
      _.intersection(selected,attrs).length > 0
  matches_special_investigations_unit_complaint_basis : ->
    selected = @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids')
    attrs = @get('special_investigations_unit_complaint_basis_ids')
    if @get('filter_criteria.basis_rule') is 'all'
      common_elements = _.intersection(selected,attrs)
      _.isEqual(common_elements.length,selected.length)
    else if (@get('filter_criteria.basis_rule') is 'any')
      _.intersection(selected,attrs).length > 0
  matches_assignee : ->
    selected_assignee_id = @get('filter_criteria.selected_assignee_id')
    assignee_id = @get('current_assignee_id')
    _.isNaN(parseInt(selected_assignee_id)) || (assignee_id == selected_assignee_id)
  matches_status : ->
    selected_statuses = @get('filter_criteria.selected_statuses')
    status_name = @get('current_status_humanized')
    (selected_statuses.indexOf(status_name) != -1) || _.isEmpty(selected_statuses)

Toggle =
  oninit : ->
    @unselect()
  toggle : ->
    @event.original.preventDefault()
    @event.original.stopPropagation()
    if @get('selected')
      @unselect()
    else
      @select()
  select : ->
    @set('selected',true)
  unselect : ->
    @set('selected',false)

StatusSelector = Ractive.extend
  template : '#status_selector_template'
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_statuses').indexOf(@get('name')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_statuses', @get('name'))
        else
          @remove_from_array('filter_criteria.selected_statuses', @get('name'))
  , Toggle

Complaint = Ractive.extend
  template : '#complaint_template'
  computed :
    delete_confirmation_message : ->
      "#{i18n.delete_complaint_confirmation_message} #{@get('case_reference')}?"
    include : ->
      @include()
    reminders_count : ->
      @get('reminders').length
    notes_count : ->
      @get('notes').length
    communications_count : ->
      @get('communications').length
    persisted : ->
      !_.isNull(@get('id'))
    persistent_attributes : ->
      ['case_reference','complainant','village','phone','mandate_name', 'imported',
        'good_governance_complaint_basis_ids', 'special_investigations_unit_complaint_basis_ids',
        'human_rights_complaint_basis_ids', 'current_status_humanized', 'new_assignee_id',
        'complaint_category_ids', 'agency_ids', 'attached_documents_attributes',
        'age', 'email', 'complained_to_subject_agency', 'desired_outcome', 'gender']
    url : ->
      Routes.complaint_path(current_locale, @get('id'))
    formatted_date :
      get: ->
        if _.isEmpty(@get('date'))
          ""
        else
          $.datepicker.formatDate("yy, M d", new Date(@get('date')) )
      set: (val)-> @set('date', $.datepicker.parseDate( "yy, M d", val))
    create_reminder_url : ->
      Routes.complaint_reminders_path('en', @get('id'))
    create_note_url : ->
      Routes.complaint_notes_path('en', @get('id'))
    complaint_basis_id_count : ->
      @get('good_governance_complaint_basis_ids').length +
      @get('special_investigations_unit_complaint_basis_ids').length +
      @get('human_rights_complaint_basis_ids').length
    validation_criteria : ->
      if @get('editing')
        complainant : ['notBlank', {if : =>!@get('imported') }]
        village : ['notBlank', {if : =>!@get('imported')}]
        mandate_name : ['match',["Good Governance","Human Rights","Special Investigations Unit"]]
        complaint_basis_id_count : ['nonZero', {if : =>!@get('imported')}]
        age : ['numeric', {if : =>!@get('imported')}]
      else
        complainant : ['notBlank', {if : =>!@get('imported') }]
        village : ['notBlank', {if : =>!@get('imported')}]
        mandate_name : ['match',["Good Governance","Human Rights","Special Investigations Unit"]]
        complaint_basis_id_count : ['nonZero', {if : =>!@get('imported')}]
        new_assignee_id : 'numeric'
        age : ['numeric', {if : =>!@get('imported')}]
  oninit : ->
    @set
      editing : false
      complainant_error: false
      village_error : false
      current_assignee_id_error : false
      mandate_name_error : false
      complaint_basis_id_count_error : false
      filetype_error: false
      filesize_error: false
      expanded:false
      serialization_key:'complaint'
    @validator = new Validator(@)
  components :
    mandates : Mandates
    mandatesSelector : MandatesSelector
    complaintBases : ComplaintBases
    complaintBasesSelector : ComplaintBasesSelector 
    agencies : Agencies
    agenciesSelector : AgenciesSelector
    complaintCategories : ComplaintCategories
    complaintCategoriesSelector : ComplaintCategoriesSelector
    assignees : Assignees
    assigneeSelector : AssigneeSelector
    attachedDocuments : ComplaintDocuments
    progressBar : ProgressBar
  expand : ->
    @set('expanded',true)
    $(@findAll('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@findAll('.collapse')).collapse('hide')
  validate : ->
    @validator.validate()
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)
  remove_errors : ->
    @compact() #nothing to do with errors, but this method is called on edit_cancel
    @restore()
  cancel_add_complaint : ->
    UserInput.reset()
    @parent.shift('complaints')
  add_file : (file)->
    attached_document =
      id : null
      complaint_id : @get('id')
      file : file
      title: ''
      file_id : ''
      url : ''
      filename : file.name
      filesize : file.size
      original_type : file.type
      serialization_key : 'complaint[complaint_documents_attributes][]'
    @unshift('attached_documents', attached_document)
  , EditBackup, Persistence, FilterMatch, @Remindable, @Notable, @Communications # Remindable, Notable and Communications are found in the _reminder.haml, _note.haml and _communication.haml files

GoodGovernanceComplaintBasisFilterSelect = Ractive.extend
  template : "#good_governance_complaint_basis_filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_good_governance_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
  , Toggle

HumanRightsComplaintBasisFilterSelect = Ractive.extend
  template : "#human_rights_complaint_basis_filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_human_rights_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
  , Toggle

SpecialInvestigationsUnitComplaintBasisFilterSelect = Ractive.extend
  template : "#special_investigations_unit_complaint_basis_filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
  , Toggle

AgencyFilterSelect = Ractive.extend
  template : "#agency_filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_agency_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_agency_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_agency_ids', @get('id'))
  , Toggle

AssigneeFilterSelect = Ractive.extend
  template : "#assignee_filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_assignee_id') == @get('id')
      set : (val)->
        if val
          @set('filter_criteria.selected_assignee_id',@get('id'))
        else
          @set('filter_criteria.selected_assignee_id',null)
  , Toggle

FilterControls = Ractive.extend
  template : "#filter_controls_template"
  components :
    goodGovernanceComplaintBasisFilterSelect : GoodGovernanceComplaintBasisFilterSelect
    humanRightsComplaintBasisFilterSelect : HumanRightsComplaintBasisFilterSelect
    specialInvestigationsUnitComplaintBasisFilterSelect : SpecialInvestigationsUnitComplaintBasisFilterSelect
    agencyFilterSelect : AgencyFilterSelect
    assigneeFilterSelect : AssigneeFilterSelect
    statusSelector : StatusSelector
  filter_rule : (type,rule)->
    @event.original.preventDefault()
    @event.original.stopPropagation()
    if rule == @get("filter_criteria.#{type}_rule")
      @set("filter_criteria.#{type}_rule", null)
    else
      @set("filter_criteria.#{type}_rule", rule)
  expand : ->
    @parent.expand()
  compact : ->
    @parent.compact()
  clear_filter : ->
    @set('filter_criteria',$.extend(true,{},complaints_page_data().filter_criteria))

window.complaints_page_data = ->
  complaints : complaints_data
  all_mandates : all_mandates
  complaint_bases : complaint_bases
  all_agencies : all_agencies
  all_agencies_in_threes : all_agencies_in_threes
  all_users : all_users
  all_categories : all_categories
  filter_criteria : filter_criteria
  all_good_governance_complaint_bases : all_good_governance_complaint_bases
  all_human_rights_complaint_bases : all_human_rights_complaint_bases
  all_special_investigations_unit_complaint_bases : all_special_investigations_unit_complaint_bases
  all_staff : all_staff
  permitted_filetypes : permitted_filetypes
  maximum_filesize : maximum_filesize
  statuses : statuses
  #complaint_named_documents_titles : ["bish", "bash", "bosh"] # shown as an example for future reference

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data : $.extend(true,{},complaints_page_data())
  oninit : ->
    @set
      'expanded' : false
  components :
    complaint : Complaint
    filterControls : FilterControls
  computed :
    selected_agency_ids : -> @findComponent('filterControls').get('agency_ids')
  new_complaint : ->
    unless @add_complaint_active()
      new_complaint =
        assigns : []
        case_reference : next_case_reference
        complainant : ""
        attached_documents : []
        current_assignee : ""
        current_assignee_id : ""
        new_assignee_id : null
        formatted_date : ""
        good_governance_complaint_basis_ids : []
        human_rights_complaint_basis_ids : []
        special_investigations_unit_complaint_basis_ids : []
        id : null
        mandate_id : null
        agency_ids : []
        notes : []
        opened_by_id : null
        phone : ""
        reminders : []
        current_status_humanized : "Under Evaluation"
        village : ""
        imported : false
        complained_to_subject_agency : false
      UserInput.claim_user_input_request(@,'cancel_add_complaint')
      @unshift('complaints',new_complaint)
  cancel_add_complaint : ->
    new_complaint = _(@findAllComponents('complaint')).find (complaint)-> !complaint.get('persisted')
    @remove(new_complaint._guid)
  remove : (guid)->
    complaint_guids = _(@findAllComponents('complaint')).map (complaint)-> complaint._guid
    index = complaint_guids.indexOf(guid)
    @splice('complaints',index,1)
  add_complaint_active : ->
    !_.isEmpty(@findAllComponents('complaint')) && !@findAllComponents('complaint')[0].get('persisted')
  set_filter_criteria_from_date : (selectedDate)->
    @set('filter_criteria.from',selectedDate)
  set_filter_criteria_to_date : (selectedDate)->
    @set('filter_criteria.to',selectedDate)
  expand : ->
    @set('expanded', true)
    _(@findAllComponents('complaint')).each (ma)-> ma.expand()
  compact : ->
    @set('expanded', false)
    _(@findAllComponents('complaint')).each (ma)-> ma.compact()

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()
  filter_criteria_datepicker.start(complaints)

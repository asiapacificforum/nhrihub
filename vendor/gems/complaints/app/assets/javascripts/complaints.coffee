#= require 'in_page_edit'
#= require 'ractive_validator'
#= require 'file_input_decorator'
#= require 'progress_bar'
#= require 'ractive_local_methods'
#= require 'string'
#= require 'jquery_datepicker'
#= require 'filter_criteria_datepicker'
#= require 'confirm_delete_modal'
#= require 'attached_documents'
#= require 'communication'
#= require 'notable'
#= require 'remindable'

@documents = new Ractive
  el : '#documents'
  template : '#documents_modal_template'
  components :
    attachedDocuments : AttachedDocuments
  showModal : ->
    $(@find('#documents_modal')).modal('show')

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
    start_callback : =>
      @set('new_assignee_id',undefined)
      ractive.expand()
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
      agency = _(window.complaints_page_data().all_agencies).findWhere(id : @get('id'))
      if _.isUndefined(agency) then null else agency.name

Agencies = Ractive.extend
  template : '#agencies_template'
  components :
    agency : Agency

MandatesSelector = Ractive.extend
  template : '#mandates_selector_template'
  remove_error : ->
    if @parent.get('mandate_id_count') != 0
      @parent.remove_attribute_error('mandate_id_count')

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
      mandate = _(window.source_complaint_bases).find (cb)=> _.isEqual(cb.key, @get(mandate).mandate)
      if _.isUndefined(mandate)
        null
      else
        complaint_basis = _(mandate.complaint_bases).find (cb)=> _.isEqual(cb.id, @get('id'))
        complaint_basis.name

ComplaintBases = Ractive.extend
  template : '#complaint_bases_template'
  components :
    complaintBasis : ComplaintBasis

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

Persistence =
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
    complaints.increment_next_case_reference(response.case_reference)
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
        url : Routes.complaint_path(current_locale, @get('id')) if @get('persisted')
        success : success
        context : context
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values

ComplaintDocuments = AttachedDocuments.extend
  oninit : ->
    @set
      parent_type : 'complaint'
      parent_named_document_datalist : @get('complaint_named_document_titles')

FilterMatch =
  include : ->
    #console.log "call include()"
    # console.log JSON.stringify "matches_complainant" : @matches_complainant(), "matches_case_reference" : @matches_case_reference(), "matches_village" : @matches_village(), "matches_date" : @matches_date(), "matches_phone" : @matches_phone(), "matches_agencies" : @matches_agencies(), "matches_assignee" : @matches_assignee(), "matches_status" : @matches_status(), "matches_basis" : @matches_basis
    # console.log JSON.stringify "matches_good_governance_complaint_basis" : @matches_good_governance_complaint_basis(), "matches_human_rights_complaint_basis" : @matches_human_rights_complaint_basis(), "matches_special_investigations_unit_complaint_basis" : @matches_special_investigations_unit_complaint_basis(), "basis_rule" : @get('filter_criteria.basis_rule'), "matches_basis" : @matches_basis(), "basis_requirement_is_specified" : @basis_requirement_is_specified(), "good_governance_basis_requirement_is_specified" : @good_governance_basis_requirement_is_specified(), "human_rights_basis_requirement_is_specified" : @human_rights_basis_requirement_is_specified(), "special_investigations_unit_basis_requirement_is_specified" : @special_investigations_unit_basis_requirement_is_specified()
    # console.log JSON.stringify "matches_area" : @matches_area()
    @matches_complainant() &&
    @matches_case_reference() &&
    @matches_village() &&
    @matches_date() &&
    @matches_phone() &&
    @matches_agencies() &&
    @matches_basis() &&
    @matches_assignee() &&
    @matches_status() &&
    @matches_area()
  matches_area : ->
    return true if !_.isNumber(@get('filter_criteria.mandate_id')) || _.isNull(@get('filter_criteria.mandate_id'))
    return parseInt(@get('mandate_id')) == parseInt(@get('filter_criteria.mandate_id'))
  matches_complainant : ->
    return true if _.isEmpty(@get('filter_criteria.complainant'))
    flexible_space_match = @get('filter_criteria.complainant').trim().replace(/\s+/g, "\\s+")
    re = new RegExp(flexible_space_match,"i")
    full_name = [@get('chiefly_title'),@get('firstName'),@get('lastName')].join(' ')
    re.test full_name
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
    return true if _.isEmpty(@get('filter_criteria.selected_agency_ids'))
    _.intersection(@get('filter_criteria.selected_agency_ids'), @get('agency_ids')).length > 0
  matches_basis : ->
    match = @matches_good_governance_complaint_basis() || # each val is undefined if no ids were selected
            @matches_human_rights_complaint_basis() || # if all of them are undefined, match is undefined
            @matches_special_investigations_unit_complaint_basis() # if any is true, true is returned
    return true if _.isUndefined(match)
    if !@basis_requirement_is_specified()
      return true
    else
      match
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
    _.intersection(selected,attrs).length > 0
  matches_human_rights_complaint_basis : ->
    selected = @get('filter_criteria.selected_human_rights_complaint_basis_ids')
    attrs = @get('human_rights_complaint_basis_ids')
    _.intersection(selected,attrs).length > 0
  matches_special_investigations_unit_complaint_basis : ->
    selected = @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids')
    attrs = @get('special_investigations_unit_complaint_basis_ids')
    _.intersection(selected,attrs).length > 0
  matches_assignee : ->
    selected_assignee_id = @get('filter_criteria.selected_assignee_id')
    assignee_id = @get('current_assignee_id')
    _.isNaN(parseInt(selected_assignee_id)) || (assignee_id == selected_assignee_id)
  matches_status : ->
    selected_statuses = @get('filter_criteria.selected_statuses')
    status_name = @get('current_status_humanized')
    _.isEmpty(selected_statuses) || (selected_statuses.indexOf(status_name) != -1)

Toggle =
  oninit : ->
    @set('selected',false)
  toggle : ->
    @event.original.preventDefault()
    @event.original.stopPropagation()
    @set('selected',!@get('selected'))

StatusSelector = Ractive.extend
  template : '#filter_select_template'
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_statuses').indexOf(@get('name')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_statuses', @get('name'))
        else
          @remove_from_array('filter_criteria.selected_statuses', @get('name'))
.extend Toggle

Complaint = Ractive.extend
  template : '#complaint_template'
  computed :
    delete_confirmation_message : ->
      "#{i18n.delete_complaint_confirmation_message} #{@get('case_reference')}?"
    include : ->
      @include()
    reminders_count : ->
      reminders = @get('reminders')
      if _.isUndefined(reminders) then 0 else reminders.length
    notes_count : ->
      notes = @get('notes')
      if _.isUndefined(notes) then 0 else notes.length
    communications_count : ->
      comms = @get('communications')
      if _.isUndefined(comms) then 0 else comms.length
    persisted : ->
      !(_.isNull(@get('id')) || _.isUndefined(@get('id')))
    persistent_attributes : ->
      ['case_reference','village','phone','mandate_ids',
        'good_governance_complaint_basis_ids', 'special_investigations_unit_complaint_basis_ids',
        'human_rights_complaint_basis_ids', 'current_status_humanized', 'new_assignee_id',
        'agency_ids', 'attached_documents_attributes', 'details',
        'dob', 'email', 'complained_to_subject_agency', 'desired_outcome', 'gender', 'date',
        'firstName', 'lastName', 'chiefly_title']
    url : ->
      Routes.complaint_path(current_locale, @get('id')) if @get('persisted')
    formatted_date :
      get: ->
        date_received = @get('date') # it's a formatted version of date_received
        if _.isEmpty(date_received)
          ""
        else
          @get('date')
      set: (val)->
        @set('date', val)
    has_errors : ->
      @validator.has_errors()
    mandate_names : ->
      mandates = _(@get('all_mandates')).select (mandate)=> _(@get('mandate_ids')).include(mandate.id)
      names = _(mandates).map (mandate)-> mandate.name
      names.join(', ')
    create_reminder_url : ->
      Routes.complaint_reminders_path('en', @get('id')) if @get('persisted')
    create_note_url : ->
      Routes.complaint_notes_path('en', @get('id')) if @get('persisted')
    complaint_basis_id_count : -> # aka subareas
      gg = @get('good_governance_complaint_basis_ids')
      ggl = if _.isUndefined(gg) then 0 else gg.length
      si = @get('special_investigations_unit_complaint_basis_ids')
      sil = if _.isUndefined(si) then 0 else si.length
      hr = @get('human_rights_complaint_basis_ids')
      hrl = if _.isUndefined(hr) then 0 else hr.length
      ggl + sil + hrl
    mandate_id_count : -> # aka 'areas'
      mandates = @get('mandate_ids')
      if _.isUndefined(mandates) then 0 else mandates.length
    validation_criteria : ->
      firstName : ['notBlank']
      lastName : ['notBlank']
      village : ['notBlank']
      mandate_id_count : 'nonZero'
      complaint_basis_id_count : 'nonZero'
      new_assignee_id : ['numeric', {if : =>!@get('editing')}]
      dob: =>
        date_regex = new RegExp(/(\d{1,2})\/(\d{1,2})\/(\d{4})/) # dd/mm/yyyy
        match = date_regex.exec @get('dob')
        valid_day = match && (parseInt(match[1]) <= 31)
        valid_month = match && (parseInt(match[2]) <= 12)
        valid_year = match && (parseInt(match[3]) <= (new Date).getFullYear()) && (parseInt(match[3]) >= 1900 )
        !_.isNull(match) && valid_day && valid_month && valid_year
      details : 'notBlank'
    error_vector : ->
      firstName_error : @get('firstName_error')
      lastName_error : @get('lastName_error')
      village_error : @get('village_error')
      new_assignee_id_error : @get('new_assignee_id_error')
      mandate_id_count_error : @get('mandate_id_count_error')
      complaint_basis_id_count_error : @get('complaint_basis_id_count_error')
      dob_error : @get('dob_error')
      details_error : @get('details_error')
  oninit : ->
    @set
      editing : false
      expanded:false
      serialization_key:'complaint'
  onconfig: ->
    @validator = new Validator(@)
  # this should work, but due to some weirdness in ractive, it doesn't, maybe a future release
  # will work better so that the callbacks can be removed from the view elements
  #onupdate: (obj)->
    #attr = _(obj).keys()[0]
    #console.log "change to #{attr}"
    #unless _.isUndefined(@validator)
      #if _(@validator.attributes).includes(attr)
        #@validate_attribute(attr)
  data :
    local : (gmt_date)->
      $.datepicker.formatDate("M d, yy", new Date(gmt_date))
  components :
    mandates : Mandates
    mandatesSelector : MandatesSelector
    complaintBases : ComplaintBases
    complaintBasesSelector : ComplaintBasesSelector 
    agencies : Agencies
    agenciesSelector : AgenciesSelector
    assignees : Assignees
    assigneeSelector : AssigneeSelector
    attachedDocuments : ComplaintDocuments
    progressBar : ProgressBar
  generate_word_doc : ->
    window.location = Routes.complaint_path('en',@get('id'),{format : 'docx'})
  expand : ->
    @set('expanded',true)
    $(@findAll('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@findAll('.collapse')).collapse('hide')
  validate : ->
    @validator.validate()
  validate_attribute : (attribute)->
    @validator.validate_attribute(attribute)
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)
  remove_errors : ->
    @compact() #nothing to do with errors, but this method is called on edit_cancel
    @restore()
  cancel_add_complaint : ->
    UserInput.reset()
    @parent.shift('complaints')
  remove : (guid)-> # required for Ractive 0.8.0, possibly can be removed in later revs
    guids = _(@findAllComponents('attachedDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('attached_documents',index,1)
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
.extend  EditBackup
.extend  Persistence
.extend  ConfirmDeleteModal
.extend  FilterMatch
.extend  @Remindable
.extend  @Notable
.extend  @Communications # Remindable Notable and Communications are found in the _reminder.haml _note.haml and _communication.haml files

GoodGovernanceComplaintBasisFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_good_governance_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
.extend Toggle

HumanRightsComplaintBasisFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_human_rights_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
.extend Toggle

SpecialInvestigationsUnitComplaintBasisFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
.extend Toggle

AgencyFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_agency_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_agency_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_agency_ids', @get('id'))
.extend Toggle

AssigneeFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_assignee_id') == @get('id')
      set : (val)->
        if val
          @set('filter_criteria.selected_assignee_id',@get('id'))
        else
          @set('filter_criteria.selected_assignee_id',null)
.extend Toggle

MandateFilterSelect = Ractive.extend
  template : "#filter_select_template"
  computed :
    selected :
      get : ->
        @get('filter_criteria.mandate_id') == @get('id')
      set : (val)->
        if val
          @set('filter_criteria.mandate_id',@get('id'))
        else
          @set('filter_criteria.mandate_id',null)
.extend Toggle

FilterControls = Ractive.extend
  template : "#filter_controls_template"
  components :
    goodGovernanceComplaintBasisFilterSelect : GoodGovernanceComplaintBasisFilterSelect
    humanRightsComplaintBasisFilterSelect : HumanRightsComplaintBasisFilterSelect
    specialInvestigationsUnitComplaintBasisFilterSelect : SpecialInvestigationsUnitComplaintBasisFilterSelect
    agencyFilterSelect : AgencyFilterSelect
    mandateFilterSelect : MandateFilterSelect
    assigneeFilterSelect : AssigneeFilterSelect
    statusSelector : StatusSelector
  expand : ->
    @parent.expand()
  compact : ->
    @parent.compact()
  clear_filter : ->
    @set('filter_criteria',$.extend(true,{},complaints_page_data().filter_criteria))
    window.history.pushState({foo: "bar"},"unused title string",window.location.origin + window.location.pathname)
    @set_filter_from_query_string()
  set_filter_from_query_string : ->
    search_string = if (_.isEmpty( window.location.search) || _.isNull( window.location.search)) then '' else window.location.search.split("=")[1]
    filter_criteria = _.extend(source_filter_criteria,{case_reference : search_string})
    @set('filter_criteria',filter_criteria)

window.complaints_page_data = ->
  complaints : source_complaints_data
  all_mandates : source_all_mandates
  complaint_bases : source_complaint_bases
  all_agencies : source_all_agencies
  all_agencies_in_sixes : source_all_agencies_in_sixes
  all_users : source_all_users
  filter_criteria : source_filter_criteria
  all_good_governance_complaint_bases : source_all_good_governance_complaint_bases
  all_human_rights_complaint_bases : source_all_human_rights_complaint_bases
  all_special_investigations_unit_complaint_bases : source_all_special_investigations_unit_complaint_bases
  all_staff : source_all_staff
  permitted_filetypes : source_permitted_filetypes
  maximum_filesize : source_maximum_filesize
  communication_permitted_filetypes : source_communication_permitted_filetypes
  communication_maximum_filesize : source_communication_maximum_filesize
  statuses : source_statuses
  next_case_reference : source_next_case_reference

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data : ->
    $.extend(true,{},complaints_page_data())
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
        case_reference : @get('next_case_reference')
        firstName : ""
        lastName : ""
        attached_documents : []
        current_assignee : ""
        current_assignee_id : ""
        new_assignee_id : null
        formatted_date : ""
        good_governance_complaint_basis_ids : []
        human_rights_complaint_basis_ids : []
        special_investigations_unit_complaint_basis_ids : []
        id : null
        mandate_ids : []
        agency_ids : []
        notes : []
        phone : ""
        reminders : []
        current_status_humanized : "Under Evaluation"
        village : ""
        complained_to_subject_agency : false
        date_received : null
        dob : null
        date_of_birth : null
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
  generate_report : ->
    window.location=Routes.complaints_path('en',{format : 'docx'})
  increment_next_case_reference : (last_ref)->
    ref_components = last_ref.split('-')
    new_ref = "#{ref_components[0]}-#{parseInt(ref_components[1])+1}"
    @set('next_case_reference', new_ref)

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

Ractive.prototype.local = (gmt_date)->
  $.datepicker.formatDate("M d, yy", new Date(gmt_date))

$ ->
  start_page()
  filter_criteria_datepicker.start(complaints)
  # so that a state object is present when returnng to the initial state with the back button
  # this is so we can discriminate returning to the page from page load
  history.replaceState({bish:"bosh"},"bash",window.location)

window.onpopstate = (event)->
  if event.state # to ensure that it doesn't trigger on page load, it's a problem with phantomjs but not with chrome
    window.complaints.findComponent('filterControls').set_filter_from_query_string()

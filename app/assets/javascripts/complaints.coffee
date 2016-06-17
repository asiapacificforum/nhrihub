//= require 'in_page_edit'
//= require 'validator'
//= require 'file_input_decorator'
//= require 'progress_bar'
//= require 'ractive_local_methods'
//= require 'string'
//= require 'jquery_datepicker'
//= require 'filter_criteria_datepicker'

Ractive.DEBUG = false

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

ComplaintBasesSelector = Ractive.extend
  template : '#complaint_bases_selector_template'

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

EditBackup =
  stash : ->
    stashed_attributes = _(@get()).pick(@get('persistent_attributes'))
    @stashed_instance = $.extend(true,{},stashed_attributes)
  restore : ->
    @restore_checkboxes()
    @set(@stashed_instance)
  restore_checkboxes : ->
    # major hack to circumvent ractive bug,
    # it will not be necessary in ractive 0.8.0
    _(['good_governance_complaint_basis','human_rights_complaint_basis','mandate','special_investigations_unit_complaint_basis', 'agency']).
      each (association)=>
        @restore_checkboxes_for(association)
  restore_checkboxes_for : (association)->
    ids = @get("#{association}_ids")
    _(@findAll(".edit .#{association} input")).each (checkbox)->
      is_checked = ids.indexOf(parseInt($(checkbox).attr('value'))) != -1
      $(checkbox).prop('checked',is_checked)

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

Persistence =
  #save_complaint : ->
    #if @validate()
      #$.ajax
        #method : 'post'
        #data : @persisted_attributes()
        #url : Routes.complaints_path('en')
        #success : @save_callback
        #context : @
  #save_callback : (data,status,jqxhr)->
    #@set(data)
  delete_complaint : (event)->
    data = {'_method' : 'delete'}
    url = Routes.complaint_path(current_locale, @get('id'))
    # TODO if confirm
    $.ajax
      method : 'post'
      url : url
      data : data
      success : @delete_callback
      dataType : 'json'
      context : @
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  save_complaint: ->
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        xhr: @progress_bar_create.bind(@)
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
        xhr: @progress_bar_create.bind(@)
        method : 'put'
        data : data
        url : Routes.complaint_path(current_locale, @get('id'))
        success : success
        context : context
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values

ProgressBar = Ractive.extend
  template : '#progress_bar_template'
  progressbar_start : ->
    # this is called for each file being uploaded
    $('.fileupload-progress.fade').addClass('in')
  progress_evaluate : (evt)->
    if evt.lengthComputable
      percentComplete = evt.loaded / evt.total
      percentComplete = parseInt(percentComplete * 100)
      $('.progress-bar').css('width',"#{percentComplete}%")
  start : ->
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener 'loadstart', @progressbar_start , false
    xhr.upload.addEventListener 'progress', @progress_evaluate , false
    xhr

ComplaintDocumentValidator = _.extend
  initialize_validator: ->
    @set 'validation_criteria',
      'file.size' :
        ['lessThan', @get('maximum_filesize')]
      'file.type' :
        ['match', @get('permitted_filetypes')]
    @set('unconfigured_validation_parameter_error',false)
  , Validator

ComplaintDocument = Ractive.extend
  template : "#complaint_document_template"
  oninit : ->
    if !@get('persisted')
      @initialize_validator()
      @validate()
  data :
    serialization_key : 'complaint[complaint_documents_attributes][]'
  computed :
    persistent_attributes : ->
      ['title', 'filename', 'file', 'original_type'] if @get('file') # only persist if there's a file object, otherwise don't
    unconfigured_filetypes_error : ->
      @get('unconfigured_validation_parameter_error')
    persisted : ->
      !_.isNull(@get('id'))
    url : ->
      Routes.complaint_document_path(current_locale, @get('id'))
  remove_file : ->
    @parent.remove(@_guid)
  delete_complaint_document : ->
    data = {'_method' : 'delete'}
    # TODO if confirm
    $.ajax
      method : 'post'
      url : @get('url')
      data : data
      success : @delete_callback
      dataType : 'json'
      context : @
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  download_attachment : ->
    window.location = @get('url')
  , ComplaintDocumentValidator

ComplaintDocuments = Ractive.extend
  template : "#complaint_documents_template"
  components :
    complaintDocument : ComplaintDocument
  remove : (guid)->
    guids = _(@findAllComponents('complaintDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('complaint_documents',index,1)

FilterMatch =
  include : ->
    #console.log JSON.stringify "matches_complainant" : @matches_complainant(), "matches_case_reference" : @matches_case_reference(), "matches_village" : @matches_village(), "matches_date" : @matches_date(), "matches_phone" : @matches_phone(), "matches_agencies" : @matches_agencies(), "matches_assignee" : @matches_assignee(), "matches_status" : @matches_status()
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
    (new Date(@get('date'))).valueOf() >= (new Date(@get('filter_criteria.from'))).valueOf()
  matches_to : ->
    return true if _.isNull(@get('date')) || _.isEmpty(@get('filter_criteria.to'))
    new Date(@get('date')) <= new Date(@get('filter_criteria.to'))
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
    closed = @get('filter_criteria.closed')
    open = @get('filter_criteria.open')
    status = @get('current_status_humanized')
    return true if closed && open
    return true if closed && status == "closed"
    return true if open && status == "open"
    return false if !closed && !open
    return false if closed && status == "open"
    return false if open && status == "closed"

Complaint = Ractive.extend
  template : '#complaint_template'
  computed :
    include : ->
      @include()
    reminders_count : ->
      @get('reminders').length
    notes_count : ->
      @get('notes').length
    persisted : ->
      !_.isNull(@get('id'))
    persistent_attributes : ->
      ['case_reference','complainant','village','phone','mandate_ids',
        'good_governance_complaint_basis_ids', 'special_investigations_unit_complaint_basis_ids',
        'human_rights_complaint_basis_ids', 'current_status_humanized', 'current_assignee_id',
        'complaint_category_ids', 'agency_ids', 'complaint_documents_attributes']
    url : ->
      Routes.complaint_path('en', @get('id'))
    formatted_date :
      get: ->
        $.datepicker.formatDate("yy, M d", new Date(@get('date')) )
      set: (val)-> @set('date', $.datepicker.parseDate( "yy, M d", val))
    create_reminder_url : ->
      Routes.complaint_reminders_path('en', @get('id'))
    create_note_url : ->
      Routes.complaint_notes_path('en', @get('id'))
  oninit : ->
    @set
      'editing' : false
      'complainant_error': false
      'title_error': false
      'complaint_error':false
      'filetype_error': false
      'filesize_error': false
      'expanded':false
      'serialization_key':'complaint'
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
    complaintDocuments : ComplaintDocuments
    progressBar : ProgressBar
  expand : ->
    @set('expanded',true)
    $(@findAll('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@findAll('.collapse')).collapse('hide')
  validate : ->
    true
  remove_attribute_error : (attribute)->
    true
  remove_errors : ->
    @compact() #nothing to do with errors, but this method is called on edit_cancel
    @restore()
  cancel_add_complaint : ->
    UserInput.reset()
    @parent.shift('complaints')
  add_file : (file)->
    @unshift('complaint_documents', {id : null, complaint_id : @get('id'), file : file, title: '', file_id : '', url : '', filename : file.name, original_type : file.type})
  show_reminders_panel : ->
    reminders.set
      reminders: @get('reminders')
      create_reminder_url : @get('create_reminder_url')
    $('#reminders_modal').modal('show')
  , EditBackup, Persistence, FilterMatch

GoodGovernanceComplaintBasisFilterSelect = Ractive.extend
  template : "#good_governance_complaint_basis_filter_select_template"
  oninit : ->
    @unselect()
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_good_governance_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_good_governance_complaint_basis_ids', @get('id'))
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

HumanRightsComplaintBasisFilterSelect = Ractive.extend
  template : "#human_rights_complaint_basis_filter_select_template"
  oninit : ->
    @unselect()
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_human_rights_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_human_rights_complaint_basis_ids', @get('id'))
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

SpecialInvestigationsUnitComplaintBasisFilterSelect = Ractive.extend
  template : "#special_investigations_unit_complaint_basis_filter_select_template"
  oninit : ->
    @unselect()
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_special_investigations_unit_complaint_basis_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_special_investigations_unit_complaint_basis_ids', @get('id'))
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

AgencyFilterSelect = Ractive.extend
  template : "#agency_filter_select_template"
  oninit : ->
    @unselect()
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_agency_ids').indexOf(@get('id')) != -1
      set : (val)->
        if val
          @push('filter_criteria.selected_agency_ids', @get('id'))
        else
          @remove_from_array('filter_criteria.selected_agency_ids', @get('id'))
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

AssigneeFilterSelect = Ractive.extend
  template : "#assignee_filter_select_template"
  oninit : ->
    @unselect()
  computed :
    selected :
      get : ->
        @get('filter_criteria.selected_assignee_id') == @get('id')
      set : (val)->
        if val
          @set('filter_criteria.selected_assignee_id',@get('id'))
        else
          @set('filter_criteria.selected_assignee_id',null)
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

FilterControls = Ractive.extend
  template : "#filter_controls_template"
  components :
    goodGovernanceComplaintBasisFilterSelect : GoodGovernanceComplaintBasisFilterSelect
    humanRightsComplaintBasisFilterSelect : HumanRightsComplaintBasisFilterSelect
    specialInvestigationsUnitComplaintBasisFilterSelect : SpecialInvestigationsUnitComplaintBasisFilterSelect
    agencyFilterSelect : AgencyFilterSelect
    assigneeFilterSelect : AssigneeFilterSelect
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
  all_users : all_users
  all_categories : all_categories
  filter_criteria : filter_criteria
  all_good_governance_complaint_bases : all_good_governance_complaint_bases
  all_human_rights_complaint_bases : all_human_rights_complaint_bases
  all_special_investigations_unit_complaint_bases : all_special_investigations_unit_complaint_bases
  all_staff : all_staff

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data : $.extend(true,{},complaints_page_data())
  components :
    complaint : Complaint
    filterControls : FilterControls
  computed :
    selected_agency_ids : -> @findComponent('filterControls').get('agency_ids')
    'filter_criteria.open' : -> _.isEqual @get('filter_criteria.selected_open_status'), ['true']
    'filter_criteria.closed' : -> _.isEqual @get('filter_criteria.selected_closed_status'), ['true']
  new_complaint : ->
    unless @add_complaint_active()
      new_complaint =
        assigns : []
        case_reference : next_case_reference
        complainant : ""
        complaint_documents : []
        current_assignee : ""
        current_assignee_id : ""
        formatted_date : ""
        good_governance_complaint_basis_ids : []
        human_rights_complaint_basis_ids : []
        special_investigations_unit_complaint_basis_ids : []
        id : null
        mandate_ids : []
        agency_ids : []
        notes : []
        opened_by_id : null
        phone : ""
        reminders : []
        status_humanized : "open"
        village : ""
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

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()
  filter_criteria_datepicker.start(complaints)

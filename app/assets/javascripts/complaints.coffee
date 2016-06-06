//= require 'in_page_edit'
//= require 'validator'

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
    stashed_attributes = _(@get()).pick(@get('params'))
    @stashed_instance = $.extend(true,{},stashed_attributes)
  restore : ->
    console.log "restore"
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
  save_complaint : ->
    if @validate()
      $.ajax
        method : 'post'
        data : @persisted_attributes()
        url : Routes.complaints_path('en')
        success : @save_callback
        context : @
  save_callback : (data,status,jqxhr)->
    @set(data)
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

Complaint = Ractive.extend
  template : '#complaint_template'
  computed :
    include : ->
      true
    reminders_count : ->
      @get('reminders').length
    notes_count : ->
      @get('notes').length
    persisted : ->
      !_.isNull(@get('id'))
    params : ->
      ['case_reference','complainant','village','phone','mandate_ids',
        'good_governance_complaint_basis_ids', 'special_investigations_unit_complaint_basis_ids',
        'human_rights_complaint_basis_ids', 'current_status_humanized', 'current_assignee_id',
        'complaint_category_ids', 'agency_ids']
    url : ->
      Routes.complaint_path('en', @get('id'))
  oninit : ->
    @set
      'editing' : false
      'complainant_error': false
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
  persisted_attributes : ->
    {complaint : _(@get()).pick(@get('params'))}
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
  , EditBackup, Persistence

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data :
    complaints : complaints_data
    all_mandates : all_mandates
    complaint_bases : complaint_bases
    all_agencies : all_agencies
    all_users : all_users
    all_categories : all_categories
  components :
    complaint : Complaint
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
        id : null
        mandate_ids : []
        agency_ids : []
        notes : []
        opened_by_id : null
        phone : ""
        reminders : []
        special_investigations_unit_complaint_basis_ids : []
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

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()


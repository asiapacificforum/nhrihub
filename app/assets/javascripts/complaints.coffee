//= require 'in_page_edit'

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
        'human_rights_complaint_basis_ids', 'status_humanized', 'current_assignee_id']
    url : ->
      Routes.complaint_path('en', @get('id'))
  oninit : ->
    @set
      'editing' : false
      'complainant_error': false
  components :
    assignees : Assignees
    mandatesSelector : MandatesSelector
    complaintBasesSelector : ComplaintBasesSelector 
    agenciesSelector : AgenciesSelector
    complaintCategories : ComplaintCategories
    complaintBases : ComplaintBases
    assigneeSelector : AssigneeSelector
  expand : ->
    @set('expanded',true)
    $(@findAll('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@findAll('.collapse')).collapse('hide')
  persisted_attributes : ->
    {complaint : _(@get()).pick(@get('params'))}
  save_complaint : ->
    if @validate()
      $.ajax
        method : 'post'
        data : @persisted_attributes()
        url : Routes.complaints_path('en')
        success : @save_callback
        context : @
  validate : ->
    true
  save_callback : (data,status,jqxhr)->
    @set(data)
  remove_attribute_error : (attribute)->
    true
  remove_errors : ->
    true
  cancel_add_complaint : ->
    @parent.shift('complaints')

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data :
    complaints : complaints_data
    all_mandates : mandates
    complaint_bases : complaint_bases
    all_agencies : agencies
    all_users : all_users
  components :
    complaint : Complaint
  new_complaint : ->
    new_complaint =
      assigns : []
      case_reference : next_case_reference
      closed_by_id : null
      closed_on : null
      complainant : ""
      complaint_documents : []
      current_assignee : ""
      current_assignee_id : ""
      formatted_date : ""
      good_governance_complaint_basis_ids : []
      human_rights_complaint_basis_ids : []
      id : null
      mandate_ids : []
      notes : []
      opened_by_id : null
      phone : ""
      reminders : []
      special_investigations_unit_complaint_basis_ids : []
      status_humanized : "open"
      village : ""
    @unshift('complaints',new_complaint)

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()


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

Assignee = Ractive.extend
  template : "#assignee_template"

Assignees = Ractive.extend
  template : "#assignees_template"
  components :
    assignee : Assignee

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
  components :
    assignees : Assignees
  expand : ->
    @set('expanded',true)
    $(@findAll('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@findAll('.collapse')).collapse('hide')

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data :
    complaints : complaints_data
  components :
    complaint : Complaint
  new_complaint : ->
    new_complaint =
      assigns : []
      case_reference : ""
      closed_by_id : null
      closed_on : null
      complainant : ""
      complaint_documents : []
      current_assignee : ""
      formatted_date : ""
      id : null
      notes : []
      opened_by_id : null
      phone : ""
      reminders : []
      status : true
      status_humanized : "open"
      village : ""
    @unshift('complaints',new_complaint)

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()

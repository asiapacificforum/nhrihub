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


Complaint = Ractive.extend
  template : '#complaint_template'
  computed :
    include : ->
      true
    reminders_count : ->
      @get('reminders').length
    notes_count : ->
      @get('notes').length

complaints_options =
  el : '#complaints'
  template : '#complaints_template'
  data :
    complaints : complaints_data
  components :
    complaint : Complaint

window.start_page = ->
  window.complaints = new Ractive complaints_options

Ractive.decorators.inpage_edit = EditInPlace

$ ->
  start_page()

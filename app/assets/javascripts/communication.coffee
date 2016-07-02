//= require 'ractive_validator'

CommunicationEdit = (node,id)->
  ractive = @
  @edit = new InpageEdit
    on : node
    object : @
    focus_element : 'input.title'
    success : (response, textStatus, jqXhr)->
      @.options.object.set(response)
      @load()
    error : ->
      console.log "Changes were not saved, for some reason"
  return {
    teardown : (id)->
    update : (id)->
    }

Ractive.decorators.communication_edit = CommunicationEdit

CommunicationDocument = Ractive.extend
  template : "comm doc"

CommunicationDocuments = Ractive.extend
  template : "{{#communication_documents}}<communicationDocument />{{/}}"
  components:
    communicationDocument : CommunicationDocument

Communication = Ractive.extend
  template : '#communication_template'
  oninit : ->
    @validator = new Validator(@)
  components :
    communicationDocuments : CommunicationDocuments
  computed :
    persisted : ->
      !isNaN(parseInt(@get('id')))
    formatted_date :
      get: ->
        $.datepicker.formatDate("yy, M d", new Date(@get('date')) )
      set: (val)->
        @set('date', $.datepicker.parseDate( "yy, M d", val))
    persistent_attributes : ->
      ['user_id', 'complaint_id', 'direction', 'mode', 'date', 'note']
  data : ->
    serialization_key : 'communication'
    validation_criteria :
      user_id : 'numeric'
      mode: ['match',['email','phone']]
      direction: ['match',['sent','received']]
  save_communication : ->
    url = Routes.complaint_communications_path(current_locale, @get('complaint_id'))
    data = @asFormData(@get('persistent_attributes'))
    if @validate()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
        method : 'post'
        data : data
        url : url
        success : @create_communication
        context : @
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  validate : ->
    @validator.validate()
  cancel_communication : ->
    @parent.pop('communications')
  delete_communication : (event)->
    ev = $.Event(event)
    ev.stopPropagation()
    data = [{name:'_method', value: 'delete'}]
    url = Routes.complaint_communication_path(current_locale,@get('complaint_id'),@get('id'))
    $.ajax
      url : url
      data : data
      method : 'post'
      dataType : 'json'
      context : @
      success : @update_communication
  update_communication : (response, statusText, jqxhr)->
    @parent.set('communications',response)
    @get('parent').set('communications',response)
  create_communication : (response, statusText, jqxhr)->
    @parent.set('communications',response)
    @get('parent').set('communications',response)
  remove_errors : (field)->
    if _.isUndefined(field) # after edit, failed save, and cancel, remove all errors
      error_attrs = _(_(@get()).keys()).select (k)-> k.match(/error/)
      _(error_attrs).each (a)=> @set(a,false)
    else # user types into input or changes select
      @set(field+"_error",false)
  add_file : (file)->
    @unshift('communication_documents', {id : null, complaint_id : @get('id'), file : file, title: '', file_id : '', url : '', filename : file.name, original_type : file.type})

@communications = new Ractive
  el : '#communication'
  template : '#communications_template'
  data : ->
    all_staff : window.all_staff
  new_communication : ->
    unless @_new_communication_is_active()
      @push('communications',{id:null, complaint_id:@get('parent').get('id'), mode : null, direction : null, date:new Date(), communication_documents : []})
  _new_communication_is_active : ->
    communications = @findAllComponents('communication')
    (communications.length > 0) && _.isNull( communications[communications.length - 1].get('id'))
  onModalClose : ->
    if @_new_communication_is_active()
      @pop('communications')

Ractive.components.communication = Communication

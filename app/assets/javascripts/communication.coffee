//= require 'ractive_validator'
//= require 'progress_bar'

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

CommunicationDocuments = Ractive.extend
  data :
    #parent : 'communication_document'
    parent : 'communication'
    parent_named_document_datalist : ->
      @get('communication_named_document_titles')
  , AttachedDocuments

ModeIcon = Ractive.extend
  template : ->
    switch @get('mode')
      when  "email"        then return "<div class='inactive-icon fa fa-at' data-toggle='tooltip' title='{{i18n.tooltip_messages.email}}' />"
      when  "phone"        then return "<div class='inactive-icon fa fa-phone' data-toggle='tooltip' title='{{i18n.tooltip_messages.phone}}' />"
      when  "letter"       then return "<div class='inactive-icon fa fa-envelope-o' data-toggle='tooltip' title='{{i18n.tooltip_messages.letter}}' />"
      when  "face to face" then return "<div class='inactive-icon face_to_face' data-toggle='tooltip' title='{{i18n.tooltip_messages.face_to_face}}'><div class='fa' /><div class='fa' /><div class='fa' /></div>"

DirectionIcon = Ractive.extend
  template : ->
    switch @get('direction')
      when "sent"     then return "<div class='inactive-icon fa fa-share' data-toggle='tooltip' title='{{i18n.tooltip_messages.sent}}' />"
      when "received" then return "<div class='inactive-icon fa fa-reply' data-toggle='tooltip' title='{{i18n.tooltip_messages.received}}' />"
      else ""

Communication = Ractive.extend
  template : '#communication_template'
  oninit : ->
    @set
      validation_criteria :
        user_id : 'numeric'
        mode: ['match',['email','phone','letter','face to face']]
        direction: =>
          # return true if attribute is valid, validator handles the error attribute
          return true if !@get('mode')
          return true if @get('mode') == 'face to face'
          return true if /sent|received/.test @get('direction')
          return false # mode is phone,email,or letter and there's no direction supplied
    @validator = new Validator(@)
  components :
    attachedDocuments : CommunicationDocuments
    modeIcon : ModeIcon
    directionIcon : DirectionIcon
    progressBar : ProgressBar
  computed :
    persisted : ->
      !isNaN(parseInt(@get('id')))
    formatted_date :
      get: ->
        $.datepicker.formatDate("yy, M d", new Date(@get('date')) )
      set: (val)->
        @set('date', $.datepicker.parseDate( "yy, M d", val))
    persistent_attributes : ->
      ['user_id', 'complaint_id', 'direction', 'mode', 'date', 'note', 'attached_documents_attributes']
    url: ->
      Routes.complaint_communication_path(current_locale, @get('complaint_id'), @get('id'))
    document_count : ->
      @get('attached_documents').length
  persisted_attributes : ->
    { communication : _.chain(@get()).pick(@get('persistent_attributes')).value() }
  data : ->
    serialization_key : 'communication'
  save_communication : ->
    url = Routes.complaint_communications_path(current_locale, @get('complaint_id'))
    data = @formData()
    if @validate()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @start_progress_bar.bind(@)
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
  start_progress_bar : ->
    @findComponent('progressBar').start()
  formData : ->
    @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
  update_persist : (success, error, context) -> # called by EditInPlace
    if @validate()
      data = @formData()
      #`for(pair of data.entries()){console.log(pair[0]+ ', '+ pair[1])}`
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @start_progress_bar.bind(@)
        method : 'put'
        data : data
        url : @get('url')
        success : success
        context : context
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
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
    @parent.set('communications',response) # the communications collection
    @get('parent').set('communications',response) # the complaint communications collection
  remove_errors : (field)->
    if _.isUndefined(field) # after edit, failed save, and cancel, remove all errors
      error_attrs = _(_(@get()).keys()).select (k)-> k.match(/error/)
      _(error_attrs).each (a)=> @set(a,false)
    else # user types into input or changes select
      @set(field+"_error",false)
  add_file : (file)->
    console.log "add_file #{JSON.stringify(_.extend({},file))}"
    attached_document =
      communication_id : @get('id')
      file : file
      file_id : ''
      file_id : null
      filename : file.name
      filesize : file.size
      id : null
      lastModifiedDate : file.lastModifiedDate
      original_type : file.type
      serialization_key : 'communication[communication_documents_attributes][]'
      title: ''
      user_id : null
    @unshift('attached_documents', attached_document)
    console.log JSON.stringify @get('attached_documents')
  , Note

@communications = new Ractive
  el : '#communication'
  template : '#communications_template'
  components :
    communication : Communication
  data : ->
    communications : []
    all_staff : window.all_staff
    i18n : window.i18n
    permitted_filetypes : window.communication_permitted_filetypes
    maximum_filesize : window.communication_maximum_filesize
  new_communication : ->
    unless @_new_communication_is_active()
      new_communication =
        id:null
        complaint_id:@get('parent').get('id')
        mode : null
        direction : null
        date:new Date()
        attached_documents : []
      @push('communications',new_communication)
  _new_communication_is_active : ->
    communications = @findAllComponents('communication')
    (communications.length > 0) && _.isNull( communications[communications.length - 1].get('id'))
  onModalClose : ->
    if @_new_communication_is_active()
      @pop('communications')

#Ractive.components.communication = Communication

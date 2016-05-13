//= require 'performance_indicator'
//= require 'fade'
//= require 'slide'
//= require 'in_page_edit'
//= require 'ractive_local_methods'
//= require 'string'

Ractive.DEBUG = false

EditInPlace = (node,id)->
  ractive = @
  edit = new InpageEdit
    object : @
    on : node
    focus_element : 'input.title'
    success : (response, statusText, jqxhr)->
       ractive = @.options.object
       @.show() # before updating b/c we'll lose the handle
       ractive.set(response)
    error : ->
      console.log "Changes were not saved, for some reason"
    start_callback : -> ractive.expand()
  teardown : =>
    edit.off()

Validator =
  validate : ->
    attributes = _(@get('validation_criteria')).keys()
    valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
    !_(valid_attributes).any (attr)->!attr
  validate_attribute : (attribute)->
    params = @get("validation_criteria")[attribute]
    [criterion,param] = if _.isArray(params) then params else [params]
    @[criterion].call(@,attribute,param)
  notBlank : (attribute)->
    @set(attribute, @get(attribute).trim())
    @set(attribute+"_error", _.isEmpty(@get(attribute)))
    !@get(attribute+"_error")
  lessThan : (attribute,param)->
    @set(attribute+"_error", @get(attribute) > param)
    !@get(attribute+"_error")
  match : (attribute,param)->
    value = @get(attribute)
    if _.isArray(param)
      if @nonEmpty("unconfigured_validation_parameter",param)
        match = _(param).any (val)->
          re = new RegExp(val)
          re.test value
      else
        # don't trigger match error if params are empty
        match = true
    else
      re = new RegExp(param)
      match = re.test value
    @set(attribute+"_error", !match)
    !@get(attribute+"_error")
  nonEmpty : (attribute,param)->
    @set(attribute+"_error", _.isEmpty(param))
    !@get(attribute+"_error")
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)

ProjectValidator = _.extend
  initialize_validator : ->
    @set 'validation_criteria',
      title : 'notBlank'
      description : 'notBlank'
  , Validator

MandatesSelector = Ractive.extend
  template : '#mandates_selector_template'

ProjectTypesSelector = Ractive.extend
  template : '#project_types_selector_template'

AgenciesSelector = Ractive.extend
  template : '#agencies_selector_template'

ConventionsSelector = Ractive.extend
  template : '#conventions_selector_template'

Mandates = Ractive.extend
  template : '#mandates_template'

ProjectTypes = Ractive.extend
  template : '#project_types_template'

Agencies = Ractive.extend
  template : '#agencies_template'

Conventions = Ractive.extend
  template : '#conventions_template'

EditBackup =
  stash : ->
    stashed_attributes = _(@get()).omit('url', 'reminders_count', 'notes_count', 'count', 'persisted', 'type', 'include')
    @stashed_instance = $.extend(true,{},stashed_attributes)
  restore : ->
    @restore_checkboxes()
    @set(@stashed_instance)
  restore_checkboxes : ->
    # major hack to circumvent ractive bug,
    # it will not be necessary in ractive 0.8.0
    _(['mandate','agency','convention','project_type']).
      each (association)=>
        @restore_checkboxes_for(association)
  restore_checkboxes_for : (association)->
    ids = @get("#{association}_ids")
    _(@findAll(".edit .#{association} input")).each (checkbox)->
      is_checked = ids.indexOf(parseInt($(checkbox).attr('value'))) != -1
      $(checkbox).prop('checked',is_checked)

ProjectDocumentValidator = _.extend
  initialize_validator: ->
    @set 'validation_criteria',
      'file.size' :
        ['lessThan', @get('maximum_filesize')]
      'file.type' :
        ['match', @get('permitted_filetypes')]
    @set('unconfigured_validation_parameter_error',false)
  , Validator

ProjectDocument = Ractive.extend
  template : "#project_document_template"
  oninit : ->
    if !@get('persisted')
      @initialize_validator()
      @validate()
  data :
    serialization_key : 'project[project_documents_attributes][]'
  computed :
    persistent_attributes : ->
      ['title', 'file']
    unconfigured_filetypes_error : ->
      @get('unconfigured_validation_parameter_error')
    persisted : ->
      !_.isNull(@get('id'))
  remove_file : ->
    @parent.remove(@_guid)
  , ProjectDocumentValidator

ProjectDocuments = Ractive.extend
  template : "#project_documents_template"
  components :
    projectDocument : ProjectDocument
  remove : (guid)->
    guids = _(@findAllComponents('projectDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('project_documents',index,1)

Persistence =
  delete_project : (event)->
    data = {'_method' : 'delete'}
    url = Routes.project_path(current_locale, @get('id'))
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
  #persisted_attributes : ->
    #project : @serialize(@get('persistent_attributes'))
  formData : ->
    #attributes = _.extend([],@get('persistent_attributes'))
    #attributes.push('project_documents_attributes')
    #@asFormData attributes
    @asFormData @get('persistent_attributes')
  update_persist : ->
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        xhr: @progress_bar_create.bind(@)
        method : 'put'
        data : data
        url : Routes.project_path(current_locale, @get('id'))
        success : @update_project_callback
        context : @
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  update_project_callback : (response, statusText, jqxhr)->
     @editor.show() # before updating b/c we'll lose the handle
     @set(response)
  save_project: ->
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        xhr: @progress_bar_create.bind(@)
        method : 'post'
        data : data
        url : Routes.projects_path(current_locale)
        success : @save_project_callback
        context : @
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  save_project_callback : (response, status, jqxhr)->
    UserInput.reset()
    @set(response)
  progress_bar_create : ->
    @findComponent('progressBar').start()

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

Project = Ractive.extend
  template : '#project_template'
  oninit : ->
    @set
      'editing' : false
      'title_error': false
      'project_error':false
      'filetype_error': false
      'filesize_error': false
      'expanded':false
      'serialization_key':'project'
    @initialize_validator()
  computed :
    persistent_attributes : ->
      # the asFormData method knows how to interpret 'project_documents_attributes'
      ['title', 'description', 'type', 'mandate_ids', 'project_type_ids',
       'agency_ids', 'convention_ids', 'performance_indicator_ids', 'project_documents_attributes']
    url : ->
      Routes.project_path(current_locale,@get('id'))
    reminders_count : ->
      @get('reminders').length
    notes_count : ->
      @get('notes').length
    count : ->
      t = @get('title') || ""
      100 - t.length
    persisted : ->
      !_.isNull(@get('id'))
    type : ->
      window.model_name
    include : ->
      # for now hard-code it
      true
  components :
    mandatesSelector : MandatesSelector
    projectTypesSelector : ProjectTypesSelector
    agenciesSelector : AgenciesSelector
    conventionsSelector : ConventionsSelector
    mandates : Mandates
    projectTypes : ProjectTypes
    agencies : Agencies
    conventions : Conventions
    projectDocuments : ProjectDocuments
    progressBar : ProgressBar
  cancel_project : ->
    UserInput.reset()
    @parent.remove(@_guid)
  expand : ->
    @set('expanded',true)
    $(@find('.collapse')).collapse('show')
  compact : ->
    @set('expanded',false)
    $(@find('.collapse')).collapse('hide')
  remove_errors : ->
    @compact() #nothing to do with errors, but this method is called on edit_cancel
    @restore()
  flash_hide : ->
    foo = ""
    #noop for now
  add_file : (file)->
    @unshift('project_documents', {id : null, project_id : @get('id'), file : file, title: '', file_id : '', url : '', filename : file.name})
    #@replaceFileInput()
  replaceFileInput : ->
    # this comes from jQuery.fileupload
    input = $(@find('#project_fileinput'))
    inputClone = input.clone(true)
    # make a form and reset it, to reset the fileinput element
    $('<form></form>').append(inputClone)[0].reset()
    # Detaching allows to insert the fileInput on another form
    # without losing the file input value:
    # detaches the original fileInput and leaves the clone in the DOM
    input.after(inputClone).detach()
    # Avoid memory leaks with the detached file input:
    $.cleanData input.unbind('remove')
  , ProjectValidator, PerformanceIndicatorAssociation, EditBackup, Persistence

MandateFilterSelect = Ractive.extend
  template : "#mandate_filter_select_template"

projects_options =
  el : "#projects"
  template : '#projects_template'
  data :
    projects : projects_data
    all_mandates : mandates
    all_agencies : agencies
    all_conventions : conventions
    planned_results : planned_results
    all_performance_indicators : performance_indicators
    project_named_documents_titles : project_named_documents_titles
    permitted_filetypes : permitted_filetypes
    maximum_filesize : maximum_filesize
  components :
    project : Project
    mandateFilterSelect : MandateFilterSelect
  new_project : ->
    unless @add_project_active()
      new_project_attributes =
        id : null
        title : ""
        description : ""
        mandate_ids : []
        project_type_ids : []
        agency_ids : []
        convention_ids : []
        performance_indicator_ids : []
        project_documents : []
      UserInput.claim_user_input_request(@,'cancel_add_project')
      @unshift('projects', new_project_attributes)
  add_project_active : ->
    !_.isEmpty(@findAllComponents('project')) && !@findAllComponents('project')[0].get('persisted')
  cancel_add_project : ->
    new_project = _(@findAllComponents('project')).find (project)-> !project.get('persisted')
    @remove(new_project._guid)
  remove : (guid)->
    project_guids = _(@findAllComponents('project')).map (pr)-> pr._guid
    index = project_guids.indexOf(guid)
    @splice('projects',index,1)
  expand_all : ->
    _(@findAllComponents('project')).each (project)->
      project.expand()
  compact_all : ->
    _(@findAllComponents('project')).each (project)->
      project.compact()

Ractive.decorators.inpage_edit = EditInPlace

window.start_page = ->
  window.projects = new Ractive projects_options

@FileInput =
  # why not use ractive event? b/c it doesn't survive the 
  # file input element replacement
  add_file : (event)->
    event.stopPropagation()
    file = event.target.files[0]
    @project = projects.findAllComponents('project')[0]
    @project.add_file(file)
    @_replace_input()
  _replace_input : ->
    # this technique comes from jQuery.fileupload
    input = $(@project.find('#project_fileinput'))
    inputClone = input.clone(true)
    # make a form and reset it. A hack to reset the fileinput element
    $('<form></form>').append(inputClone)[0].reset()
    # Detaching allows to insert the fileInput on another form
    # without losing the file input value:
    # detaches the original fileInput and leaves the clone in the DOM
    input.after(inputClone).detach()
    # Avoid memory leaks with the detached file input:
    $.cleanData input.unbind('remove')

$ ->
  start_page()

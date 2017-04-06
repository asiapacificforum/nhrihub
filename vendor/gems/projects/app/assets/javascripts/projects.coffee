//= require 'confirm_delete_modal'
//= require 'performance_indicator'
//= require 'fade'
//= require 'slide'
//= require 'in_page_edit'
//= require 'ractive_local_methods'
//= require 'string'
//= require 'validator'
//= require 'file_input_decorator'
//= require 'progress_bar'
//= require 'jquery_datepicker'
//= require 'filter_criteria_datepicker'
//= require 'confirm_delete_modal'
//= require 'remindable'
//= require 'notable'

Ractive.DEBUG = false

EditInPlace = (node,id)->
  ractive = @
  edit = new InpageEdit
    object : @
    on : node
    focus_element : 'input.title'
    #success : (response, statusText, jqxhr)->
       #ractive = @.options.object
       #@.show() # before updating b/c we'll lose the handle
       #ractive.set(response)
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

AreasSelector = Ractive.extend
  template : '#areas_selector_template'

ProjectTypesSelector = Ractive.extend
  template : '#project_types_selector_template'

Areas = Ractive.extend
  template : '#areas_template'

ProjectTypes = Ractive.extend
  template : '#project_types_template'

EditBackup =
  stash : ->
    stashed_attributes = _(@get()).omit('url', 'reminders_count', 'notes_count', 'count', 'persisted', 'type', 'include', 'expanded', 'editing')
    @stashed_instance = $.extend(true,{},stashed_attributes)
  restore : ->
    @restore_checkboxes()
    @set(@stashed_instance)
  restore_checkboxes : ->
    # major hack to circumvent ractive bug,
    # it will not be necessary in ractive 0.8.0
    _(['area','project_type']).
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
      ['title', 'filename', 'file', 'original_type'] unless @get('id') # only persist if it's not already persisted, otherwise don't
    unconfigured_filetypes_error : ->
      @get('unconfigured_validation_parameter_error')
    persisted : ->
      !_.isNull(@get('id'))
    url : ->
      Routes.project_document_path(current_locale, @get('id'))
    truncated_title : ->
      @get('title').split(' ').slice(0,4).join(' ')+"..."
    truncated_title_or_filename : ->
      unless _.isEmpty(@get('title'))
        @get('truncated_title')
      else
        @get('filename')
    delete_confirmation_message : ->
      "#{delete_project_document_confirmation_message} \"#{@get('truncated_title_or_filename')}\"?"
  remove_file : ->
    @parent.remove(@_guid)
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  download_attachment : ->
    window.location = @get('url')
  , ProjectDocumentValidator, ConfirmDeleteModal

ProjectDocuments = Ractive.extend
  template : "#project_documents_template"
  components :
    projectDocument : ProjectDocument
  remove : (guid)->
    guids = _(@findAllComponents('projectDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('project_documents',index,1)

Persistence = $.extend
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  formData : ->
    @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
  update_persist : (success, error, context) -> # called by EditInPlace
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
        method : 'put'
        data : data
        url : Routes.project_path(current_locale, @get('id'))
        #success : @update_project_callback
        success : success
        #context : @
        context : context
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  #update_project_callback : (response, statusText, jqxhr)->
     #@editor.show() # before updating b/c we'll lose the handle
     #@set(response)
  save_project: ->
    if @validate()
      data = @formData()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
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
  , ConfirmDeleteModal

FilterMatch =
  include : ->
    @matches_title() &&
    @matches_area() &&
    @matches_project_type() &&
    @matches_performance_indicator()
  matches_title : ->
    re = new RegExp(@get('filter_criteria.title').trim(),"i")
    re.test @get('title')
  matches_area : ->
    criterion = @get('filter_criteria.area_ids')
    value = @get('area_ids')
    @contains(criterion,value)
  matches_project_type : ->
    criterion = @get('filter_criteria.project_type_ids')
    value = @get('project_type_ids')
    @contains(criterion,value)
  matches_performance_indicator : ->
    criterion = parseInt(@get('filter_criteria.performance_indicator_id'))
    value = parseInt(@get('performance_indicator_id'))
    return true if _.isUndefined(criterion) || _.isNaN(criterion)
    _.isEqual(criterion, value)
  contains : ( criterion, value) ->
    return true if _.isEmpty(criterion)
    common_elements = _.intersection(criterion, value)
    # must have some common elements
    !_.isEmpty(common_elements)

Project = Ractive.extend
  template : '#project_template'
  oninit : ->
    @set
      'editing' : false
      'title_error': false
      'description_error': false
      'performance_indicator_associations_error': false
      'project_error':false
      'filetype_error': false
      'filesize_error': false
      'expanded':false
      'serialization_key':'project'
  computed :
    performance_indicator_required : -> true
    persistent_attributes : ->
      # the asFormData method knows how to interpret 'project_documents_attributes'
      ['title', 'description', 'area_ids', 'project_type_ids',
       'selected_performance_indicators_attributes', 'project_documents_attributes']
    url : ->
      Routes.project_path(current_locale,@get('id'))
    truncated_title : ->
      @get('title').split(' ').slice(0,4).join(' ')+"..."
    delete_confirmation_message : ->
      "#{delete_project_confirmation_message} \"#{@get('truncated_title')}\"?"
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
      @include()
    create_note_url : ->
      window.create_note_url.replace('id',@get('id'))
    create_reminder_url : ->
      window.create_reminder_url.replace('id',@get('id'))
    has_errors : ->
      #@has_errors()
      attributes = _(@get('validation_criteria')).keys()
      error_attributes = _(attributes).map (attr)->attr+"_error"
      _(error_attributes).any (attr)=>@get(attr)
    validation_criteria : ->
      title : 'notBlank'
      description : 'notBlank'
      performance_indicator_associations : ['nonEmpty', @get('performance_indicator_associations')]
  components :
    areasSelector : AreasSelector
    projectTypesSelector : ProjectTypesSelector
    areas : Areas
    projectTypes : ProjectTypes
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
  remove_attribute_error : (attr)->
    @set(attr+"_error", false)
  add_file : (file)->
    project =
      id : null
      project_id : @get('id')
      file : file
      title: ''
      file_id : ''
      url : ''
      filename : file.name
      original_type : file.type
    @unshift('project_documents', project)
  show_file_selector : ->
    @find('#project_fileinput').click()
  , Validator, PerformanceIndicatorAssociation, EditBackup, Persistence, FilterMatch, Remindable, Notable

FilterSelect = Ractive.extend
  computed :
    selected : ->
      _(@get("filter_criteria.#{@get('collection')}")).indexOf(@get('id')) != -1
  toggle : (id)->
    @event.original.preventDefault()
    @event.original.stopPropagation()
    if @get("selected")
      @unselect()
    else
      @select()
  select : ->
    @push("filter_criteria.#{@get('collection')}",@get('id'))
  unselect : ->
    @set("filter_criteria.#{@get('collection')}", _(@get("filter_criteria.#{@get('collection')}")).without(@get('id')))

AreaFilterSelect = Ractive.extend
  template : "#area_filter_select_template"
  computed :
    collection : ->
      "area_ids"
  , FilterSelect

ProjectTypeFilterSelect = Ractive.extend
  template : "#project_type_filter_select_template"
  computed :
    collection : ->
      "project_type_ids"
  , FilterSelect

PerformanceIndicatorFilterSelect = Ractive.extend
  template: "#performance_indicator_filter_select_template"
  select : (id)->
    if @get('filter_criteria.performance_indicator_id') == id
      @set('filter_criteria.performance_indicator_id',null)
    else
      @set('filter_criteria.performance_indicator_id',id)

FilterControls = Ractive.extend
  template : "#filter_controls_template"
  components :
    areaFilterSelect : AreaFilterSelect
    projectTypeFilterSelect : ProjectTypeFilterSelect
    performanceIndicatorFilterSelect : PerformanceIndicatorFilterSelect
  expand : ->
    @parent.expand()
  compact : ->
    @parent.compact()
  clear_filter : ->
    @set('filter_criteria', window.projects_page_data().filter_criteria)
    window.history.pushState({foo: "bar"},"unused title string",window.location.origin + window.location.pathname)
    @set_filter_from_query_string()
  set_filter_from_query_string : ->
    search_string = if (_.isEmpty( window.location.search) || _.isNull( window.location.search)) then '' else window.location.search.split("=")[1].replace(/\+/g,' ')
    filter_criteria = _.extend(window.filter_criteria,{title : search_string})
    @set('filter_criteria',filter_criteria)

window.projects_page_data = ->
  performance_indicator_url : Routes.project_performance_indicator_path(current_locale,'id')
  expanded : false
  projects : projects_data
  all_areas : areas
  planned_results : planned_results
  all_performance_indicators : performance_indicators
  all_area_project_types : project_types
  project_named_documents_titles : project_named_documents_titles
  permitted_filetypes : permitted_filetypes
  maximum_filesize : maximum_filesize
  filter_criteria : filter_criteria

projects_options = ->
  el : "#projects"
  template : '#projects_template'
  data : $.extend(true,{},projects_page_data())
  components :
    project : Project
    filterControls : FilterControls
  new_project : ->
    unless @add_project_active()
      new_project_attributes =
        id : null
        title : ""
        description : ""
        area_ids : []
        project_type_ids : []
        performance_indicator_associations : []
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
  expand : ->
    @set('expanded',true)
    _(@findAllComponents('project')).each (project)->
      project.expand()
  compact : ->
    @set('expanded',false)
    _(@findAllComponents('project')).each (project)->
      project.compact()

Ractive.decorators.inpage_edit = EditInPlace

window.start_page = ->
  window.projects = new Ractive projects_options()

$ ->
  start_page()
  # so that a state object is present when returnng to the initial state with the back button
  # this is so we can discriminate returning to the page from page load
  history.replaceState({bish:"bosh"},"bash",window.location)

window.onpopstate = (event)->
  if event.state # to ensure that it doesn't trigger on page load, it's a problem with phantomjs but not with chrome
    window.projects.findComponent('filterControls').set_filter_from_query_string()

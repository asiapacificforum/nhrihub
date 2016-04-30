#= require 'performance_indicator'
#= require 'fade'
#= require 'slide'
#= require 'in_page_edit'

Ractive.DEBUG = false
$ ->
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

  ProjectValidator =
    data :
      validation_criteria :
        title : 'notBlank'
        description : 'notBlank'
    validate : ->
      attributes = _(@get('validation_criteria')).keys()
      valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
      invalid_attribute_exists = _(valid_attributes).indexOf(false)
      invalid_attribute_exists == -1
    validate_attribute : (attribute)->
      criterion = @get('validation_criteria')[attribute]
      @[criterion].call(@,attribute)
    notBlank : (attribute)->
      @set(attribute, @get(attribute).trim())
      @set(attribute+"_error", _.isEmpty(@get(attribute)))
      !@get(attribute+"_error")
    remove_attribute_error : (attribute)->
      @set(attribute+"_error",false)

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
    computed :
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
    create_instance_attributes : ->
      project :
        title : @get('title')
        description : @get('description')
        type : @get('type')
        mandate_ids : @value_or_empty('mandate_ids')
        project_type_ids : @value_or_empty('project_type_ids')
        agency_ids : @value_or_empty('agency_ids')
        convention_ids : @value_or_empty('convention_ids')
        performance_indicator_ids : @value_or_empty('performance_indicator_ids')
    save_project : ->
      data = @create_instance_attributes()
      url = Routes.projects_path(current_locale)
      if @validate()
        $.ajax
          method : 'post'
          data : data
          url : url
          success : @save_project_callback
          context : @
    value_or_empty : (attr)->
      if _.isEmpty(@get(attr))
       [""]
      else
       @get(attr)
    save_project_callback : (response, status, jqxhr)->
      UserInput.reset()
      @set(response)
    cancel_project : ->
      UserInput.reset()
      @parent.remove(@_guid)
    expand : ->
      @set('expanded',true)
      $(@find('.collapse')).collapse('show')
    compact : ->
      @set('expanded',false)
      $(@find('.collapse')).collapse('hide')
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
    remove_errors : ->
      @compact() #nothing to do with errors, but this method is called on edit_cancel
      @restore()
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
    remove_performance_indicator : (id)->
      index = @get('performance_indicator_ids').indexOf(id)
      @get('performance_indicator_ids').splice(index,1)
    , ProjectValidator

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
    components :
      project : Project
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
        UserInput.claim_user_input_request(@,'cancel_add_project')
        @unshift('projects', new_project_attributes)
    add_project_active : ->
      !@findAllComponents('project')[0].get('persisted')
    cancel_add_project : ->
      new_project = _(@findAllComponents('project')).find (project)-> !project.get('persisted')
      @remove(new_project._guid)
    remove : (guid)->
      project_guids = _(@findAllComponents('project')).map (pr)-> pr._guid
      index = project_guids.indexOf(guid)
      @splice('projects',index,1)

  Ractive.decorators.inpage_edit = EditInPlace

  window.start_page = ->
    window.projects = new Ractive projects_options

  start_page()


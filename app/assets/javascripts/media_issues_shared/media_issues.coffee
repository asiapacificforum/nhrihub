$ ->
  Collection.EditInPlace = (node,id)->
    ractive = @
    @edit = new InpageEdit
      on : node
      object : @
      focus_element : 'input.title'
      success : (response, textStatus, jqXhr)->
        @.options.object.set(response)
        @.options.object.parent.populate_min_max_fields() # b/c value could be edited so that edited collection item is hidden by filter, so reset filter to make sure it stays in view
        @load()
      error : ->
        console.log "Changes were not saved, for some reason"
      start_callback : -> ractive.expand()
    return {
      teardown : (id)->
      update : (id)->
      }

  Ractive.DEBUG = false

  Ractive.decorators.inpage_edit = Collection.EditInPlace

  Collection.CollectionItemSubarea = Ractive.extend
    template : '#collection_item_subarea_template'
    computed :
      name : ->
        _(subareas).findWhere({id : @get('id')}).name

  Collection.CollectionItemArea = Ractive.extend
    template : '#collection_item_area_template'
    computed :
      name : ->
        _(areas).findWhere({id : @get('area_id')}).name
    components :
      collectionitemsubarea : Collection.CollectionItemSubarea

  Collection.Metric = Ractive.extend
    template : '#metric_template'

  Selectable =
    oninit : ->
      @select()
    toggle : ->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      if @get("#{@get('attr')}_selected")
        @unselect()
      else
        @select()
    select : ->
      @root.add_filter(@get('attr'),@get('id'))
      @set("#{@get('attr')}_selected",true)
    unselect : ->
      @root.remove_filter(@get('attr'),@get('id'))
      @set("#{@get('attr')}_selected",false)

  SelectableArea = _.extend
    data :
      attr : "area"
  , Selectable

  SelectableSubarea = _.extend
    data :
      attr : "subarea"
  , Selectable

  Collection.SubareaFilter = Ractive.extend
    template : '#subarea_template'
  , SelectableSubarea

  Collection.AreaFilter = Ractive.extend
    template : '#area_template'
    components :
      subarea : Collection.SubareaFilter
  , SelectableArea

  # not currently used, until Ractive 0.8.0 is reliable
  Collection.SubareaSelect = Ractive.extend
    template : "#subarea_select_template"
    show_metrics : (id)->
      if (Collection.Subarea.find(id).extended_name == "Human Rights Violation") && @get('checked')
        $('.hr_metrics').show(300)
      else if (Collection.Subarea.find(id).extended_name == "Human Rights Violation") && !@get('checked')
        $('.hr_metrics').hide(300)

  # not currently used, until Ractive 0.8.0 is reliable
  Collection.AreaSelect = Ractive.extend
    template : "#area_select_template"
    components :
      'subarea-select' : Collection.SubareaSelect

  Collection.FileUpload = (node)->
    $(node).fileupload
      dataType: 'json'
      type: 'post'
      add: (e, data) -> # data includes a files property containing added files and also a submit property
        upload_widget = $(@).data('blueimp-fileupload')
        ractive = data.ractive = Ractive.
          getNodeInfo(upload_widget.element[0]).
          ractive
        data.context = upload_widget.element.closest(".#{item_name}")
        ractive.set('fileupload', data) # so ractive can configure/control upload with data.submit()
        ractive.set('original_filename', data.files[0].name)
        ractive.validate_file_constraints()
        ractive._validate_attachment()
        return
      done: (e, data) ->
        data.ractive.update_collection_item(data.jqXHR.responseJSON)
        return
      formData : ->
        @ractive.formData()
      uploadTemplateId: '#selected_file_template'
      uploadTemplateContainerId: '#selected_file_container'
      downloadTemplateId: '#show_collection_item_template'
      permittedFiletypes: permitted_filetypes
      maxFileSize: parseInt(maximum_filesize)
    teardown : ->
      #noop for now

  Ractive.decorators.file_upload = Collection.FileUpload

  Collection.File = Ractive.extend
    template : "#selected_file_template"
    deselect_file : ->
      @parent.deselect_file()

  Collection.CollectionItem = Ractive.extend
    template : '#collection_item_template'
    components :
      collectionItemArea : Collection.CollectionItemArea
      metric : Collection.Metric
      file : Collection.File
      # due to a ractive bug, checkboxes don't work in components,
      # see http://stackoverflow.com/questions/32891814/unexpected-behaviour-of-ractive-component-with-checkbox,
      # so this component is not used, until the bug is fixed
      # update: bug is fixed in "edge" but many other problems prevent using it
      # 'area-select' : AreaSelect
    oninit : ->
      @set
        'editing' : false
        'title_error': false
        'collection_item_error':false
        'collection_item_double_attachment_error':false
        'filetype_error': false
        'filesize_error': false
        'expanded':false
    computed :
      reminders_count : ->
        @get('reminders').length
      notes_count : ->
        @get('notes').length
      model_name : ->
        item_name
      hr_violation : ->
        id = Collection.Subarea.hr_violation().id
        _(@get('subarea_ids')).indexOf(id) != -1
      formatted_metrics : ->
        metrics = $.extend(true,{},@get('metrics'))
        if !_.isNull(affected_people_count)
          affected_people_count = @get('metrics').toLocaleString()
        metrics
      count : ->
        t = @get('title') || ""
        100 - t.length
      include : ->
        @get('editing') ||
          (@_matches_title() &&
          @_matches_from() &&
          @_matches_to() &&
          @_matches_area_subarea() &&
          @_matches_violation_coefficient() &&
          @_matches_positivity_rating() &&
          @_matches_violation_severity() &&
          @_matches_people_affected())
      persisted : ->
        !_.isNull(@get('id'))
      match_vector : ->
        matches_from : @_matches_from()
        matches_to : @_matches_to()
        matches_area_subarea : @_matches_area_subarea()
        matches_area : @_matches_area()
        matches_subarea: @_matches_subarea()
        matches_people_affected : @_matches_people_affected()
        matches_violation_severity : @_matches_violation_severity()
        matches_violation_coefficient : @_matches_violation_coefficient()
        matches_positivity_rating : @_matches_positivity_rating()
        matches_title: @_matches_title()
    _matches_from : ->
      new Date(@get('date')) >= new Date(@get('filter_criteria.from'))
    _matches_to : ->
      new Date(@get('date')) <= new Date(@get('filter_criteria.to'))
    _matches_area_subarea : ->
      return (@_matches_area() || @_matches_subarea()) if @get('filter_criteria.rule') == 'any'
      return (@_matches_area() && @_matches_subarea()) if @get('filter_criteria.rule') == 'all'
    _matches_area : ->
      if @get('filter_criteria.rule') == 'any'
        return true if _.isEmpty(@get('area_ids'))
        matches = _.intersection(@get('area_ids'), @get('filter_criteria.areas'))
        matches.length > 0
      else
        _.isEqual(@get('area_ids').slice().sort(), @get('filter_criteria.areas').slice().sort())
    _matches_subarea : ->
      if @get('filter_criteria.rule') == 'any'
        matches = _.intersection(@get('subarea_ids'), @get('filter_criteria.subareas'))
        matches.length > 0
      else
        return true if _.isEmpty(@get('filter_criteria.subareas'))
        _.isEqual(@get('subarea_ids').slice().sort(), @get('filter_criteria.subareas').slice().sort())
    _matches_people_affected : ->
      if @get('hr_violation')
        value = parseInt(@get('affected_people_count'))
        value = 0 if !_.isNumber(value) || _.isNaN(value) # null value is interpreted as zero for hr_violation instances
      else
        value = 0
      @_between(parseInt(@get('filter_criteria.pa_min')),parseInt(@get('filter_criteria.pa_max')),value)
    _matches_violation_severity : ->
      # note, violation_severity_rank_text is a string of the form "4: some text here", but parseInt converts appropriately!
      if @get('hr_violation')
        value = parseInt(@get('violation_severity_rank_text'))
        value = 0 if !_.isNumber(value) || _.isNaN(value) # null value is interpreted as zero for hr_violation instances
      else
        value = 0
      @_between(parseInt(@get('filter_criteria.vs_min')),parseInt(@get('filter_criteria.vs_max')),value)
    _matches_violation_coefficient : ->
      if @get('hr_violation')
        value = parseFloat(@get('violation_coefficient'))
        value = 0 if !_.isNumber(value) || _.isNaN(value) # null value is interpreted as zero for hr_violation instances
      else
        value = 0
      @_between(parseFloat(@get('filter_criteria.vc_min')),parseFloat(@get('filter_criteria.vc_max')),value)
    _matches_positivity_rating : ->
      # note, positivity_rating_rank_text is a string of the form "4: some text here", but parseInt converts appropriately!
      @_between(parseInt(@get('filter_criteria.pr_min')),parseInt(@get('filter_criteria.pr_max')),parseInt(@get("positivity_rating_rank_text")))
    _between : (min,max,val)->
      return true if _.isNaN(val) # declare match if there's no value
      min = if _.isNaN(min) # from the input element a zero-length string can be presented
              0
            else
              min
      exceeds_min = (val >= min)
      less_than_max = _.isNaN(max) || (val <= max) # if max is not a number, then assume val is in-range
      exceeds_min && less_than_max
    _matches_title : ->
      re = new RegExp(@get('filter_criteria.title'),'i')
      re.test(@get('title'))
    expand : ->
      @set('expanded',true)
      $(@find('.collapse')).collapse('show')
    compact : ->
      @set('expanded',false)
      $(@find('.collapse')).collapse('hide')
    show_reminders_panel : ->
      reminders.set
        reminders: @get('reminders')
        create_reminder_url : @get('create_reminder_url')
      $('#reminders_modal').modal('show')
    show_notes_panel : ->
      notes.set
        notes : @get('notes')
        create_note_url : @get('create_note_url')
      $('#notes_modal').modal('show')
    remove_title_errors : ->
      @set('title_error',false)
    cancel : ->
      UserInput.reset()
      @parent.shift('collection_items')
    form : ->
      $('.form input, .form select')
    save : ->
      if @validate()
        if !_.isUndefined(@get('fileupload'))
          @get('fileupload').submit() # handled by jquery-fileupload
        else
          url = @parent.get('create_collection_item_url')
          $.post(url, @create_instance_attributes(), @update_collection_item, 'json') # handled right here
    validate : ->
      vt = @_validate_title()
      va = @_validate_attachment()
      vt && va
    _validate_title : ->
      @set('title',@get('title').trim())
      if _.isEmpty(@get('title'))
        @set('title_error',true)
        false
      else
        true
    _validate_attachment : ->
      @_validate_any_attachment() && @_validate_single_attachment()
    _validate_any_attachment : ->
      unless @_validate_file() || @_validate_link()
        @set('collection_item_error',true)
        false
      else
        @set('collection_item_error',false)
        true
    _validate_single_attachment : ->
      if @_validate_file() && @_validate_link()
        @set('collection_item_double_attachment_error',true)
        false
      else
        @set('collection_item_double_attachment_error',false)
        true
    _validate_file : ->
      # 3 cases to consider:
      if !@get('persisted') # 1. not persisted... creating new, with file attached
        !_.isNull(@get('original_filename')) && @validate_file_constraints()
      else
        if _.isEmpty(@get('fileupload')) # 2. persisted, only original_filename attribute is present
          !_.isNull(@get('original_filename'))
        else # 3. persisted, changing the attached file, so a fileupload object is present
          !_.isNull(@get('original_filename')) && @validate_file_constraints()
    _validate_link : ->
      !_.isNull(@get('article_link')) && @get('article_link').length > 0
    validate_file_constraints : ->
      file = @get('fileupload').files[0]
      size = file.size
      extension = @get('fileupload').files[0].name.split('.').pop()
      if permitted_filetypes.indexOf(extension) == -1
        @set('filetype_error', true)
      else
        @set('filetype_error', false)
      if size > maximum_filesize
        @set('filesize_error', true)
      else
        @set('filesize_error', false)
      !@get('filetype_error') && !@get('filesize_error')
    #remove_attachment_errors : ->
      #@set('collection_item_double_attachment_error',false)
      #@set('collection_item_error',false)
    update_collection_item : (data,textStatus,jqxhr)->
      collection.set('collection_items.0', data)
      collection.populate_min_max_fields() # to ensure that the newly-added collection_item is included in the filter
      UserInput.reset()
      if !_.isUndefined(@edit)
        @edit.load() # terminate edit, if it was active, but don't try to restore stashed instance
    delete_this : (event) ->
      data = {'_method' : 'delete'}
      url = @get('url')
      # TODO if confirm
      $.ajax
        method : 'post'
        url : url
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      @parent.delete(@)
    remove_errors : ->
      @compact() #nothing to do with errors, but this method is called on edit_cancel
      @restore()
    _attrs : ->
      attrs = ['file', 'title', 'affected_people_count', 'violation_severity_id', 'article_link', 'lastModifiedDate']
      attrs.push('positivity_rating_id') if item_name == "media_appearance"
      attrs
    create_instance_attributes: ->
      attrs = _(@get()).pick(@_attrs())
      if _.isEmpty(@get('performance_indicator_ids'))
        attrs.performance_indicator_ids = [""]
      else
        attrs.performance_indicator_ids = @get('performance_indicator_ids')
      if _.isEmpty(@get('area_ids'))
        attrs.area_ids = [""] # hack to workaround jQuery not sending empty arrays
      else
        attrs.area_ids = @get('area_ids')
      if _.isEmpty(@get('subarea_ids'))
        attrs.subarea_ids = [""]
      else
        attrs.subarea_ids = @get('subarea_ids')
      {"#{item_name}" : attrs }
    formData : ->
      file = @get('fileupload').files[0]
      @set
        lastModifiedDate : file.lastModifiedDate
      attrs = _(@get()).pick(@_attrs())
      name_value = _(attrs).keys().map (k)->{name:"#{item_name}["+k+"]", value:attrs[k]}
      if _.isEmpty(@get('area_ids'))
        aids = [{name : "#{item_name}[area_ids][]", value: ""}]
      else
        aids = _(@get('area_ids')).map (aid)->
                 {name : "#{item_name}[area_ids][]", value: aid}
      if _.isEmpty(@get('subarea_ids'))
        saids = [{name : "#{item_name}[subarea_ids][]", value: ""}]
      else
        saids = _(@get('subarea_ids')).map (said)->
                  {name : "#{item_name}[subarea_ids][]", value: said}
      if _.isEmpty(@get('performance_indicator_ids'))
        pids = [{name : "#{item_name}[performance_indicator_ids][]", value: ""}]
      else
        pids = _(@get('performance_indicator_ids')).map (pid)->
                  {name : "#{item_name}[performance_indicator_ids][]", value: pid}
      _.union(name_value,aids,saids,pids)
    stash : ->
      @stashed_instance = $.extend(true,{},@get())
    restore : ->
      @set(@stashed_instance)
    deselect_file : ->
      file_input = $(@find("##{item_name}_file"))
      # see http://stackoverflow.com/questions/1043957/clearing-input-type-file-using-jquery
      file_input.replaceWith(file_input.clone()) # the actual file input field
      @set('fileupload',null) # remove all traces!
      @set('original_filename',null) # remove all traces!
      @set('file','_remove')
      @validate()
    update_persist : (success, error, context) ->
      if _.isEmpty(@get('fileupload')) # handle the update directly
        $.ajax
          url: @get('url')
          method : 'put'
          data : @create_instance_attributes()
          success : success
          error : error
          context : context
      else # handle it with jquery fileupload
        $('.fileupload').fileupload('option',{url:@get('url'), type:'put', formData:@formData()})
        @get('fileupload').submit()
    download_attachment : ->
      window.location = @get('url')
    fetch_link : ->
      redirectWindow = window.open(@get('article_link'), '_blank')
      redirectWindow.location
    show_metrics : (ev, id)->
      if (Collection.Subarea.find(id).extended_name == "Human Rights Violation") && ev.target.checked
        $('.hr_metrics').show(300)
      else if (Collection.Subarea.find(id).extended_name == "Human Rights Violation") && !ev.target.checked
        $('.hr_metrics').hide(300)
  , PerformanceIndicatorAssociation

  window.collection_items_data = -> # an initialization data set so that tests can reset between
    expanded : false
    collection_items: collection_items
    areas : areas
    create_collection_item_url: create_collection_item_url
    planned_results : planned_results
    all_performance_indicators : performance_indicators
    item_name : item_name
    filter_criteria :
      title : ""
      from : new Date(new Date().toDateString()) # so that the time is 00:00, vs. the time of instantiation
      to : new Date(new Date().toDateString()) # then it yields proper comparison with Rails timestamp
      areas : []
      subareas : []
      vc_min : 0.0
      vc_max : null
      pr_min : 0
      pr_max : null
      vs_min : 0
      vs_max : null
      pa_min : 0
      pa_max : null
      rule   : 'any'

  window.options =
    el : '#collection_container'
    template : '#collection_template'
    data : window.collection_items_data()
    oninit : ->
      @populate_min_max_fields()
    computed :
      dates : ->
        _(@findAllComponents('collectionItem')).map (collectionItem)->new Date(collectionItem.get('date'))
      violation_coefficients : ->
        _(@findAllComponents('collectionItem')).map (collectionItem)->parseFloat (collectionItem.get("violation_coefficient") || 0.0 )
      positivity_ratings : ->
        _(@findAllComponents('collectionItem')).map (collectionItem)->parseInt( parseInt(collectionItem.get("positivity_rating_rank_text"))  || 0)
      violation_severities : ->
        _(@findAllComponents('collectionItem')).map (collectionItem)->parseInt( parseInt(collectionItem.get("violation_severity_rank_text"))  || 0)
      people_affecteds : ->
        _(@findAllComponents('collectionItem')).map (collectionItem)->parseInt( collectionItem.get("affected_people_count")  || 0)
      earliest : ->
        @min('dates')
      most_recent : ->
        @max('dates')
      vc_min : ->
        @min('violation_coefficients')
      vc_max : ->
        @max('violation_coefficients')
      pr_min : ->
        @min('positivity_ratings')
      pr_max : ->
        @max('positivity_ratings')
      vs_min : ->
        @min('violation_severities')
      vs_max : ->
        @max('violation_severities')
      pa_min : ->
        @min('people_affecteds')
      pa_max : ->
        @max('people_affecteds')
      formatted_from_date:
        get: -> $.datepicker.formatDate("dd/mm/yy", @get('filter_criteria.from'))
        set: (val)-> @set('filter_criteria.from', $.datepicker.parseDate( "dd/mm/yy", val))
      formatted_to_date:
        get: -> $.datepicker.formatDate("dd/mm/yy", @get('filter_criteria.to'))
        set: (val)-> @set('filter_criteria.to', $.datepicker.parseDate( "dd/mm/yy", val))
    min : (param)->
      @get(param).reduce (min,val)->
        return val if val<min
        min
    max : (param)->
      @get(param).reduce (max,val)->
        return val if val > max
        max
    components :
      collectionItem : Collection.CollectionItem
      area : Collection.AreaFilter
    populate_min_max_fields : ->
      @set('filter_criteria.from',@get('earliest'))  unless _.isUndefined(@get('earliest'))
      @set('filter_criteria.to',@get('most_recent')) unless _.isUndefined(@get('most_recent'))
      @set('filter_criteria.vc_min',@get('vc_min'))  unless _.isUndefined(@get('vc_min'))
      @set('filter_criteria.vc_max',@get('vc_max'))  unless _.isUndefined(@get('vc_max'))
      @set('filter_criteria.pr_min',@get('pr_min'))  unless _.isUndefined(@get('pr_min'))
      @set('filter_criteria.pr_max',@get('pr_max'))  unless _.isUndefined(@get('pr_max'))
      @set('filter_criteria.vs_min',@get('vs_min'))  unless _.isUndefined(@get('vs_min'))
      @set('filter_criteria.vs_max',@get('vs_max'))  unless _.isUndefined(@get('vs_max'))
      @set('filter_criteria.pa_min',@get('pa_min'))  unless _.isUndefined(@get('pa_min'))
      @set('filter_criteria.pa_max',@get('pa_max'))  unless _.isUndefined(@get('pa_max'))
    expand : ->
      @set('expanded', true)
      _(@findAllComponents('collectionItem')).each (collectionItem)-> collectionItem.expand()
    compact : ->
      @set('expanded', false)
      _(@findAllComponents('collectionItem')).each (collectionItem)-> collectionItem.compact()
    add_filter : (attr,id)->
      @push("filter_criteria.#{attr}s",id)
    remove_filter : (attr,id)->
      i = _(@get("filter_criteria.#{attr}s")).indexOf(id)
      @splice("filter_criteria.#{attr}s",i,1)
    clear_filter : ->
      @set('filter_criteria',collection_items_data().filter_criteria)
      _(@findAllComponents('area')).each (a)-> a.select()
      _(@findAllComponents('subarea')).each (a)-> a.select()
      @populate_min_max_fields()
    set_defaults : ->
      @clear_filter()
    filter_rule : (name)->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      @set('filter_criteria.rule',name)
    new_article : ->
      @unshift('collection_items', $.extend(true,{},new_collection_item))
      $(@find("##{item_name}_title")).focus()
      UserInput.claim_user_input_request(@,'cancel')
    delete : (child)->
      index = @findAllComponents('collectionItem').indexOf(child)
      @splice('collection_items',index,1)
    cancel : ->
      @shift('collection_items')
    set_filter_criteria_to_date : (selectedDate)->
      @set('filter_criteria.to',$.datepicker.parseDate("dd/mm/yy",selectedDate))
      $('#from').datepicker 'option', 'maxDate', selectedDate
      @update()
    set_filter_criteria_from_date : (selectedDate)->
      @set('filter_criteria.from',$.datepicker.parseDate("dd/mm/yy",selectedDate))
      $('#to').datepicker 'option', 'minDate', selectedDate
      @update()

  window.start_page = ->
    window.collection = new Ractive options
    filter_criteria_datepicker.start(collection)

  start_page()

# validate the filter_criteria input fields whenever they change
  collection.observe 'filter_criteria.*', (newval, oldval, path)->
    key = path.split('.')[1]

    has_error = ->
      return _.isNaN(parseFloat(newval)) if key.match(/vc_min|vc_max/)
      return _.isNaN(parseInt(newval)) if key.match(/pr_min|pr_max|pa_min|pa_max|vs_min|vs_max/)

    if has_error() && !_.isEmpty(newval)
      $(".#{key}").addClass('error')
    else
      $(".#{key}").removeClass('error')


$ ->
  EditInPlace = (node,id)->
    ractive = @
    @edit = new InpageEdit
      on : node
      object : @
      focus_element : 'input.title'
      success : (response, textStatus, jqXhr)->
        @.options.object.set(response)
        @.options.object.parent.populate_min_max_fields() # b/c value could be edited so that edited media appearance is hidden by filter, so reset filter to make sure it stays in view
        @load()
      error : ->
        console.log "Changes were not saved, for some reason"
      start_callback : -> ractive.expand()
    return {
      teardown : (id)->
      update : (id)->
      }

  Ractive.DEBUG = false

  window.app_debug = false

  Ractive.decorators.inpage_edit = EditInPlace

  MediaSubarea = Ractive.extend
    template : '#media_subarea_template'
    computed :
      name : ->
        _(subareas).findWhere({id : @get('id')}).name

  MediaArea = Ractive.extend
    template : '#media_area_template'
    computed :
      name : ->
        _(areas).findWhere({id : @get('area_id')}).name
    components :
      mediasubarea : MediaSubarea

  Metric = Ractive.extend
    template : '#metric_template'

  SubareaFilter = Ractive.extend
    template : '#subarea_template'
    oninit : ->
      @select()
    toggle : ->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      if @get('subarea_selected')
        @unselect()
      else
        @select()
    select : ->
      @root.add_subarea_filter(@get('id'))
      @set('subarea_selected',true)
    unselect : ->
      @root.remove_subarea_filter(@get('id'))
      @set('subarea_selected',false)

  AreaFilter = Ractive.extend
    template : '#area_template'
    components :
      subarea : SubareaFilter
    oninit : ->
      @select()
    toggle : ->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      if @get('area_selected')
        @unselect()
      else
        @select()
    select : ->
      #_(@findAllComponents('subarea')).each (sa)-> sa.select() # causes subareas to be initialized twice
      @root.add_area_filter(@get('id'))
      @set('area_selected',true)
    unselect : ->
      #_(@findAllComponents('subarea')).each (sa)-> sa.unselect()
      @root.remove_area_filter(@get('id'))
      @set('area_selected',false)

  # not currently used, until Ractive 0.8.0 is reliable
  SubareaSelect = Ractive.extend
    template : "#subarea_select_template"
    show_metrics : (id)->
      if (Subarea.find(id).extended_name == "Human Rights Violation") && @get('checked')
        $('.hr_metrics').show(300)
      else if (Subarea.find(id).extended_name == "Human Rights Violation") && !@get('checked')
        $('.hr_metrics').hide(300)

  # not currently used, until Ractive 0.8.0 is reliable
  AreaSelect = Ractive.extend
    template : "#area_select_template"
    components :
      'subarea-select' : SubareaSelect

  fileupload_options =
    permittedFiletypes: permitted_filetypes,
    maxFileSize: parseInt(maximum_filesize),
    failed: (e,data)->
      if data.errorThrown != 'abort'
        alert("The upload failed for some reason")
    prependFiles : false
    filesContainer: '#media_appearances'
    formData: ->
      console.log "getting formdata"
      inputs = @context.find(':input') # TODO must take formdata from the ractive instance not the dom
      inputs.serializeArray()
    downloadTemplateId: '#template-download'
    uploadTemplateId: '#template-upload'
    uploadTemplateContainerId: '.template-upload'
    fileInput : ".template-upload #fileinput_button input:file"

  FileUpload = (node)->
    ractive = Ractive.getNodeInfo(node).ractive
    $(node).fileupload _.extend(fileupload_options, {ractive : ractive})
    teardown : ->
      #noop for now

  MediaAppearance = Ractive.extend
    template : '#media_appearance_template'
    components :
      mediaarea : MediaArea
      metric : Metric
      # due to a ractive bug, checkboxes don't work in components,
      # see http://stackoverflow.com/questions/32891814/unexpected-behaviour-of-ractive-component-with-checkbox,
      # so this component is not used, until the bug is fixed
      # update: bug is fixed in "edge" but many other problems prevent using it
      'area-select' : AreaSelect
    decorators :
      file_upload : FileUpload
    oninit : ->
      @set({'title_error': false, 'expanded':false})
    computed :
      hr_violation : ->
        id = Subarea.find_by_extended_name("Human Rights Violation").id
        _(@get('subarea_ids')).indexOf(id) != -1
      debug : -> app_debug
      formatted_metrics : ->
        metrics = $.extend(true,{},@get('metrics'))
        metrics.affected_people_count.value = @get('metrics').affected_people_count.value.toLocaleString()
        metrics
      count : ->
        t = @get('title') || ""
        100 - t.length
      include : ->
        if @get('debug')
          true
        else
          @_matches_title() &&
          @_matches_from() &&
          @_matches_to() &&
          @_matches_area_subarea() &&
          @_matches_violation_coefficient() &&
          @_matches_positivity_rating() &&
          @_matches_violation_severity() &&
          @_matches_people_affected()
      matches_title : -> # the 'matches' attributes are for diagnosis during dev and can be removed
        @_matches_title()
      matches_from : ->
        @_matches_from()
      matches_to : ->
        @_matches_to()
      matches_area : ->
        @_matches_area()
      matches_subarea : ->
        @_matches_subarea()
      matches_area_subarea : ->
        @_matches_area_subarea()
      matches_violation_coefficient : ->
        @_matches_violation_coefficient()
      matches_positivity_rating : ->
        @_matches_positivity_rating()
      matches_violation_severity : ->
        @_matches_violation_severity()
      matches_people_affected : ->
        @_matches_people_affected()
      persisted : ->
        !_.isNull(@get('id'))
    _matches_from : ->
      new Date(@get('date')) >= new Date(@get('sort_criteria.from'))
    _matches_to : ->
      new Date(@get('date')) <= new Date(@get('sort_criteria.to'))
    _matches_area_subarea : ->
      return (@_matches_area() || @_matches_subarea()) if @get('sort_criteria.rule') == 'any'
      return (@_matches_area() && @_matches_subarea()) if @get('sort_criteria.rule') == 'all'
    _matches_area : ->
      if @get('sort_criteria.rule') == 'any'
        return true if _.isEmpty(@get('area_ids'))
        matches = _.intersection(@get('area_ids'), @get('sort_criteria.areas'))
        matches.length > 0
      else
        _.isEqual(@get('area_ids').slice().sort(), @get('sort_criteria.areas').slice().sort())
    _matches_subarea : ->
      if @get('sort_criteria.rule') == 'any'
        matches = _.intersection(@get('subarea_ids'), @get('sort_criteria.subareas'))
        matches.length > 0
      else
        return true if _.isEmpty(@get('sort_criteria.subareas'))
        _.isEqual(@get('subarea_ids').slice().sort(), @get('sort_criteria.subareas').slice().sort())
    _matches_people_affected : ->
      @_between(parseInt(@get('sort_criteria.pa_min')),parseInt(@get('sort_criteria.pa_max')),parseInt(@get('metrics.affected_people_count.value')))
    _matches_violation_severity : ->
      @_between(parseInt(@get('sort_criteria.vs_min')),parseInt(@get('sort_criteria.vs_max')),parseInt(@get('metrics.violation_severity.value')))
    _matches_violation_coefficient : ->
      @_between(parseFloat(@get('sort_criteria.vc_min')),parseFloat(@get('sort_criteria.vc_max')),parseFloat(@get('metrics.violation_coefficient.value')))
    _matches_positivity_rating : ->
      @_between(parseInt(@get('sort_criteria.pr_min')),parseInt(@get('sort_criteria.pr_max')),parseInt(@get("metrics.positivity_rating.rank")))
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
      re = new RegExp(@get('sort_criteria.title'),'i')
      re.test(@get('title'))
    expand : ->
      @set('expanded',true)
      $(@find('.collapse')).collapse('show')
    compact : ->
      @set('expanded',false)
      $(@find('.collapse')).collapse('hide')
    show_reminders_panel : ->
      $('#reminders_modal').modal('show')
    show_notes_panel : ->
      $('#notes_modal').modal('show')
    remove_title_errors : ->
      @set('title_error',false)
    cancel : ->
      @parent.shift('media_appearances')
    form : ->
      $('.form input, .form select')
    save : ->
      url = @parent.get('create_media_appearance_url')
      if @validate()
        $(@el).find('.start').trigger('click')
        #$.post(url, @create_instance_attributes(), @update_ma, 'json')
    validate : ->
      @set('title',@get('title').trim())
      if _.isEmpty(@get('title'))
        @set('title_error',true)
        false
      else
        true
    update_ma : (data,textStatus,jqxhr)->
      media.set('media_appearances.0', data)
      media.populate_min_max_fields() # to ensure that the newly-added media_appearance is included in the filter
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
    create_instance_attributes : ->
      attrs = _(@get()).pick('title', 'affected_people_count', 'violation_severity_id', 'positivity_rating_id')
      if _.isEmpty(@get('area_ids'))
        attrs.area_ids = [""] # hack to workaround jQuery not sending empty arrays
      else
        attrs.area_ids = @get('area_ids')
      if _.isEmpty(@get('subarea_ids'))
        attrs.subarea_ids = [""]
      else
        attrs.subarea_ids = @get('subarea_ids')
      {media_appearance : attrs}
    stash : ->
      @stashed_instance = $.extend(true,{},@get())
    restore : ->
      @set(@stashed_instance)

  window.media_page_data = -> # an initialization data set so that tests can reset between
    expanded : false
    media_appearances: media_appearances
    areas : areas
    create_media_appearance_url: create_media_appearance_url
    sort_criteria :
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
    el : '#media_appearances'
    template : '#media_appearances_template'
    data : window.media_page_data()
    oninit : ->
      @populate_min_max_fields()
    computed :
      dates : ->
        _(@findAllComponents('ma')).map (ma)->new Date(ma.get('date'))
      violation_coefficients : ->
        _(@findAllComponents('ma')).map (ma)->parseFloat (ma.get("metrics.violation_coefficient.value") || 0.0 )
      positivity_ratings : ->
        _(@findAllComponents('ma')).map (ma)->parseInt( ma.get("metrics.positivity_rating.rank")  || 0)
      violation_severities : ->
        _(@findAllComponents('ma')).map (ma)->parseInt( ma.get("metrics.violation_severity.rank")  || 0)
      people_affecteds : ->
        _(@findAllComponents('ma')).map (ma)->parseInt( ma.get("metrics.affected_people_count.value")  || 0)
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
        get: -> $.datepicker.formatDate("dd/mm/yy", @get('sort_criteria.from'))
        set: (val)-> @set('sort_criteria.from', $.datepicker.parseDate( "dd/mm/yy", val))
      formatted_to_date:
        get: -> $.datepicker.formatDate("dd/mm/yy", @get('sort_criteria.to'))
        set: (val)-> @set('sort_criteria.to', $.datepicker.parseDate( "dd/mm/yy", val))
    min : (param)->
      @get(param).reduce (min,val)->
        return val if val<min
        min
    max : (param)->
      @get(param).reduce (max,val)->
        return val if val > max
        max
    components :
      ma : MediaAppearance
      area : AreaFilter
    populate_min_max_fields : ->
      @set('sort_criteria.from',@get('earliest'))  unless _.isUndefined(@get('earliest'))
      @set('sort_criteria.to',@get('most_recent')) unless _.isUndefined(@get('most_recent'))
      @set('sort_criteria.vc_min',@get('vc_min'))  unless _.isUndefined(@get('vc_min'))
      @set('sort_criteria.vc_max',@get('vc_max'))  unless _.isUndefined(@get('vc_max'))
      @set('sort_criteria.pr_min',@get('pr_min'))  unless _.isUndefined(@get('pr_min'))
      @set('sort_criteria.pr_max',@get('pr_max'))  unless _.isUndefined(@get('pr_max'))
      @set('sort_criteria.vs_min',@get('vs_min'))  unless _.isUndefined(@get('vs_min'))
      @set('sort_criteria.vs_max',@get('vs_max'))  unless _.isUndefined(@get('vs_max'))
      @set('sort_criteria.pa_min',@get('pa_min'))  unless _.isUndefined(@get('pa_min'))
      @set('sort_criteria.pa_max',@get('pa_max'))  unless _.isUndefined(@get('pa_max'))
    expand : ->
      @set('expanded', true)
      _(@findAllComponents('ma')).each (ma)-> ma.expand()
    compact : ->
      @set('expanded', false)
      _(@findAllComponents('ma')).each (ma)-> ma.compact()
    #expand_toggle : ->
      #state = @get('expanded')
      #@set('expanded',!state)
      #if @get('expanded')
        #_(@findAllComponents('ma')).each (ma)-> ma.compact()
      #else
        #_(@findAllComponents('ma')).each (ma)-> ma.expand()
    add_area_filter : (id) ->
      @push('sort_criteria.areas',id)
    remove_area_filter : (id) ->
      i = _(@get('sort_criteria.areas')).indexOf(id)
      @splice('sort_criteria.areas',i,1)
    add_subarea_filter : (id) ->
      @push('sort_criteria.subareas',id)
    remove_subarea_filter : (id) ->
      i = _(@get('sort_criteria.subareas')).indexOf(id)
      @splice('sort_criteria.subareas',i,1)
    clear_filter : ->
      @set('sort_criteria',media_page_data().sort_criteria)
      _(@findAllComponents('area')).each (a)-> a.select()
      _(@findAllComponents('subarea')).each (a)-> a.select()
      @populate_min_max_fields()
    set_defaults : ->
      @clear_filter()
    filter_rule : (name)->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      @set('sort_criteria.rule',name)
    new_article : ->
      @unshift('media_appearances', $.extend(true,{},new_media_appearance))
      $(@find('#media_appearance_title')).focus()
    delete : (media_appearance)->
      index = @findAllComponents('ma').indexOf(media_appearance)
      @splice('media_appearances',index,1)


  window.start_page = ->
    window.media = new Ractive options

  start_page()

# validate the sort_criteria input fields whenever they change
  media.observe 'sort_criteria.*', (newval, oldval, path)->
    key = path.split('.')[1]

    has_error = ->
      return _.isNaN(parseFloat(newval)) if key.match(/vc_min|vc_max/)
      return _.isNaN(parseInt(newval)) if key.match(/pr_min|pr_max|pa_min|pa_max|vs_min|vs_max/)

    if has_error() && !_.isEmpty(newval)
      $(".#{key}").addClass('error')
    else
      $(".#{key}").removeClass('error')


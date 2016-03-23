$ ->
  MonitorEdit = (node,id)->
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

  Ractive.decorators.monitor_edit = MonitorEdit

  Ractive.DEBUG = false

  Monitor =
    computed :
      persisted : ->
        !isNaN(parseInt(@get('id')))
      formatted_date :
        get: ->
          $.datepicker.formatDate("M d, yy", new Date(@get('date')) )
        set: (val)-> 
          @set('date', $.datepicker.parseDate( "M d, yy", val))
    save_monitor : ->
      url = @parent.get('create_monitor_url')
      data = {monitor : _.chain(@get()).pick(@get('params')).extend({type:@get('type')}).value() }
      if @validate(data)
        $.ajax
          type : 'post'
          url : url
          data : data
          dataType : 'json'
          success : @create_monitor
          context : @
    cancel_monitor : ->
      @parent.pop(@parent.get('collection'))
    delete_monitor : (event)->
      ev = $.Event(event)
      ev.stopPropagation()
      # data = [{name:'_method', value: 'delete'},{name : 'type', value : @get('type')}]
      data = {'_method': 'delete', monitor : {type: @get('type')}}
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @update_monitor
    update_monitor : (resp, statusText, jqxhr)->
      @parent.set(resp)
    create_monitor : (response, statusText, jqxhr)->
      @parent.update_monitors(response)
    remove_errors : (field)->
      if _.isUndefined(field) # after edit, failed save, and cancel, remove all errors
        error_attrs = _(_(@get()).keys()).select (k)-> k.match(/error/)
        _(error_attrs).each (a)=> @set(a,false)
      else # user types into input or changes select
        @set(field+"_error",false)
    set_date_from_datepicker : (selectedDate)->
      @set('date',$.datepicker.parseDate("yy, M d",selectedDate))

  NumericMonitor = Ractive.extend
    template : '#numeric_monitor_template'
    computed :
      type : -> "NumericMonitor"
      params : ->
        ["value","date","indicator_id"]
    validate : ->
      if _.isNaN(value = parseFloat(@get('value')))
        @set('value_error',true)
      else
        @set
          'value_error':false
          'value':value
      !@get('value_error')
  , Monitor

  TextMonitor = Ractive.extend
    template : '#text_monitor_template'
    computed :
      type : -> "TextMonitor"
      params : ->
        ["description","date","indicator_id"]
    validate : ->
      @_validate('description')
    _validate : (field)->
      if _.isString(@get(field))
        @set(field, @get(field).trim())
      value = @get(field)
      if _.isArray(value) && value.length == 0
        @set(field+'_error',true)
        false
      else if value == "" || _.isNull(value)
        @set(field+'_error',true)
        false
      else
        true
  , Monitor

  FileMonitor = Ractive.extend
    template : '#file_monitor_template'
    computed :
      type : -> "FileMonitor"
      params : ->
        ["indicator_id","author_id","file_id","filesize","original_filename","original_type"]
  , Monitor

  window.monitors = new Ractive
    el: '#monitor'
    template : "#monitors_template"
    computed :
      collection : ->
        "#{@get('monitor_format')}_monitors"
    new_monitor : ->
      unless @_new_monitor_is_active()
        @push(@get('collection'),{id:null, date: new Date, value:null, indicator_id:@get('id'), formatted_date : $.datepicker.formatDate("M d, yy", new Date())})
    _new_monitor_is_active : ->
      monitors = @findAllComponents("#{@get('monitor_format')}Monitor")
      (monitors.length > 0) && _.isNull( monitors[monitors.length - 1].get('id'))
    onModalClose : ->
      if @_new_monitor_is_active()
        collection = "#{@get('monitor_format')}_monitors"
        @pop(collection)
    update_monitors : (monitors) ->
      collection = "#{@get('monitor_format')}_monitors"
      @set(collection,monitors)
      @get('source').set(collection,monitors)

  Popover = (node)->
    indicator = @
    $(node).popover
      html : true,
      title : ->
        $('#detailsTitle').html()
      content : ->
        data = indicator.get()
        if data.monitor_format == "numeric"
          template = "#numericMonitorDetailsContent"
        else
          template = "#detailsContent"
        ractive = new Ractive
          template : template
          data : data
        ractive.toHTML()
      template : $('#popover_template').html()
      trigger: 'hover'
    teardown: ->
      $(node).off('mouseenter')

  Datepicker = (node)->
    $(node).datepicker
      maxDate: null
      defaultDate: new Date()
      changeMonth: true
      changeYear: true
      numberOfMonths: 1
      dateFormat: "yy, M d"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          object = Ractive.getNodeInfo(node).ractive
          object.set_date_from_datepicker(selectedDate)
    teardown : ->
      $(node).datepicker('destroy')

  Ractive.decorators.datepicker = Datepicker
  Ractive.decorators.popover = Popover
  Ractive.components.numericMonitor = NumericMonitor
  Ractive.components.textMonitor = TextMonitor
  Ractive.components.fileMonitor = FileMonitor

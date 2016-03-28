$ ->
  Offence = Ractive.extend
    template : "<div class='col-md-2' style='width:{{column_width}}%'> {{description}} </div>"
    computed :
      column_width : ->
        l = @parent.get('offences').length
        100/l

  Offences = Ractive.extend
    template : "{{#offences}} <offence description='{{description}}' /> {{/offences}}"
    components :
      offence : Offence

  FileUpload = (node)->
    $(node).fileupload
      dataType: 'json'
      type: 'post'
      add: (e, data) -> # data includes a files property containing added files and also a submit property
        upload_widget = $(@).data('blueimp-fileupload')
        ractive = data.ractive = Ractive.
          getNodeInfo(upload_widget.element[0]).
          ractive
        # ractive is the file_monitor ractive instance
        data.context = upload_widget.element.closest(".monitor")
        ractive.set('fileupload', data) # so ractive can configure/control upload with data.submit()
        #ractive.set('original_filename', data.files[0].name)
        ractive.findComponent("selectedFile").set( _.extend({},data.files[0]) )
        ractive.validate_file_constraints()
        return
      done: (e, data) ->
        data.ractive.update_file(data.jqXHR.responseJSON)
        return
      formData : ->
        @ractive.formData()
      uploadTemplateId: '#upload_template'
      uploadTemplateContainerId: '#selected_file_container'
      downloadTemplateId: '#download_file_template'
      permittedFiletypes: permitted_filetypes
      maxFileSize: parseInt(maximum_filesize)
    teardown : ->
      #noop for now

  Ractive.decorators.file_upload = FileUpload

  SelectedFile = Ractive.extend
    #template : "<span id='selected_file'>{{name}}</span>"
    template : "#upload_template"

  MonitorPopover = (node)->
    indicator = @
    $(node).popover
      html : true,
      title : ->
        $('#detailsTitle').html()
      content : ->
        data = indicator.get()
        if data.monitor_format == "numeric"
          template = "#numericMonitorDetailsContent"
        else if data.monitor_format == "text"
          template = "#textMonitorDetailsContent"
        else
          template = "#fileMonitorDetailsContent"
        ractive = new Ractive
          template : template
          data : data
        ractive.toHTML()
      template : $('#popover_template').html()
      trigger: 'hover'
    teardown: ->
      $(node).off('mouseenter')

  window.file_monitor = new Ractive
    el: "#file_monitor"
    template : "#file_monitor_template"
    computed :
      url : ->
        if @get('persisted')
          Routes.nhri_indicator_file_monitor_path(current_locale, @get('indicator_id'), @get('id'))
        else
          Routes.nhri_indicator_file_monitors_path(current_locale, @get('indicator_id'))
      persisted : ->
        !_.isUndefined @get('id')
      save_method : ->
        if @get('persisted')
          'put'
        else
          'post'
    decorators :
      popover : MonitorPopover
    components :
      selectedFile : SelectedFile
    formData : ->
      'monitor[original_filename]' : @findComponent('selectedFile').get('name')
      'monitor[original_type]' : @findComponent('selectedFile').get('type')
      'monitor[filesize]' : @findComponent('selectedFile').get('size')
    onModalClose : ->
      @findComponent('selectedFile').reset()
    validate_file_constraints : ->
      file = @get('fileupload').files[0]
      size = file.size
      extension = file.name.split('.').pop()
      @set('filetype_error', permitted_filetypes.indexOf(extension) == -1 )
      @set('filesize_error', size > maximum_filesize )
      @findComponent('selectedFile').set('filesize_error',@get('filesize_error'))
      @findComponent('selectedFile').set('filetype_error',@get('filetype_error'))
      !@get('filetype_error') && !@get('filesize_error')
    save_file : ->
      if @validate_file_constraints()
        $('.fileupload').fileupload('option',{method : @get('save_method'), url:@get('url'), formData:@formData()})
        @get('fileupload').submit()
    update_file : (response)->
      @findComponent('selectedFile').reset()
      @set(response)
    download_file : ->
      window.location = @get('url')

  Indicator = Ractive.extend
    template : "#indicator_template"
    computed :
      monitors_count : ->
        if @get('monitor_format') == "numeric"
          @get('numeric_monitors').length
        else if @get('monitor_format') == "text"
          @get('text_monitors').length
        else if _.isNumber @get('file_monitor.id')
          1
        else
          0
      reminders_count : ->
        @get('reminders').length
      notes_count : ->
        @get('notes').length
    show_reminders_panel : ->
      reminders.set
        reminders: @get('reminders')
        create_reminder_url : Routes.nhri_indicator_reminders_path(current_locale,@get('id'))
      $('#reminders_modal').modal('show')
    show_notes_panel : ->
      notes.set
        notes : @get('notes')
        create_note_url : Routes.nhri_indicator_notes_path(current_locale,@get('id'))
      $('#notes_modal').modal('show')
    show_monitors_panel : ->
      type = @get('monitor_format')
      if type == 'file'
        if _.isNull(@get('file_monitor'))
          file_monitor.reset({indicator_id : @get('id')})
        else
          file_monitor.set(@get('file_monitor'))
        $('#file_monitor_modal').modal('show')
      else
        monitors.set
          numeric_monitors : @get('numeric_monitors')
          text_monitors : @get('text_monitors')
          numeric_monitor_explanation : @get('numeric_monitor_explanation')
          monitor_format : @get('monitor_format')
          indicator_id : @get('id')
          source : @
        $("##{type}_monitors_modal").modal('show')
    delete_indicator : (event,obj)->
      data = [{name:'_method', value: 'delete'}]
      url = Routes.nhri_heading_indicator_path(current_locale,@get('heading_id'),@get('id'))
      $.ajax
        method: 'post'
        url: url
        data: data
        success: @delete_callback
        context: @
    delete_callback : ->
      @parent.remove_indicator(@get('id'))
    edit_indicator : ->
      new_indicator.set(@get())
      new_indicator.set('source',@)
      $('#new_indicator_modal').modal('show')

  NatureOffence = Ractive.extend
    template : "#nature_offence_template"
    components :
      indicator : Indicator
    new_indicator : ->
      new_indicator.set
        title : ""
        nature : @get('nature')
        offence_id : @get('offence_id')
        heading_id : @get('heading_id')
        monitor_format : ""
        id : null
      $('#new_indicator_modal').modal('show')
    remove_indicator : (id)->
      nature = @get('nature')
      indicators = nature+'_indicators'
      indicator_ids = _(@get(indicators)).map (i)-> i.id
      index = indicator_ids.indexOf(id)
      @splice(indicators,index,1)

  NatureAllOffences = Ractive.extend
    template : "#nature_all_offences_template"
    components :
      indicator : Indicator
    new_indicator : ->
      new_indicator.set
        title : ""
        nature : @get('nature')
        offence_id : null
        heading_id : @get('heading_id')
        monitor_format : ""
        id : null
      $('#new_indicator_modal').modal('show')
    remove_indicator : (id)->
      nature = @get('nature')
      indicators = 'all_offence_'+nature+'_indicators'
      indicator_ids = _(@get(indicators)).map (i)-> i.id
      index = indicator_ids.indexOf(id)
      @splice(indicators,index,1)

  Nature = Ractive.extend
    template : "#nature_template"
    computed :
      collection_name : ->
        "all_offence_"+@get('name')+"_indicators"
      all_offence_indicators : ->
        @get(@get('collection_name'))
    components :
      natureOffence : NatureOffence
      natureAllOffences : NatureAllOffences

  Natures = Ractive.extend
    template : "#natures_template"
    components :
      nature : Nature

  window.heading = new Ractive
    el: "#heading"
    template : "#heading_template"
    data:
      id : heading_data.id
      offences : heading_data.offences
      natures : natures
      all_offence_structural_indicators : heading_data.all_offence_structural_indicators
      all_offence_process_indicators : heading_data.all_offence_process_indicators
      all_offence_outcomes_indicators : heading_data.all_offence_outcomes_indicators
    components :
      offences : Offences
      natures : Natures
    add_indicator : (indicator)->
      nature = indicator.nature
      if _.isNull(indicator.offence_id)
        @push("all_offence_#{nature}_indicators",indicator)
      else
        offence_index = _(@get('offences').map (o)->o.id).indexOf(indicator.offence_id)
        @push("offences.#{offence_index}.#{nature}_indicators",indicator)

# position the labels in the corner box, it depends on column height
  window.position_labels = ->
    height = $('.row-eq-height').height()
    width = $('#corner').width()
    ll_vert_pos = (height/2) + (height-50)/3
    ll_right_pos = 51-(height-50)/8
    hr_left_pos = 44+(height-50)/44
    $('#low-left').css('top', ll_vert_pos+'px').css('right',ll_right_pos+'px').show()
    $('#high-right').css('bottom',height/2+'px').css('left',hr_left_pos+'px').show()
  position_labels()

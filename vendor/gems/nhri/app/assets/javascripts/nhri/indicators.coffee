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
        data.context = upload_widget.element.closest(".monitor")
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
      uploadTemplateId: '#upload_template'
      uploadTemplateContainerId: '#selected_file_container'
      downloadTemplateId: '#download_file_template'
      permittedFiletypes: permitted_filetypes
      maxFileSize: parseInt(maximum_filesize)
    teardown : ->
      #noop for now

  Ractive.decorators.file_upload = FileUpload

  # window.file_monitor = new Ractive
  FileMonitor = Ractive.extend
    template : "#file_monitor_template"
    onModalClose : ->
      console.log "closing"
    validate_file_constraints: ->
      true
    _validate_attachment : ->
      true
    save_file : ->
      console.log "saving in FileMonitor"

  Indicator = Ractive.extend
    template : "#indicator_template"
    components :
      fileMonitor : FileMonitor
    computed :
      monitors_count : ->
        if @get('monitor_format') == "numeric"
          @get('numeric_monitors').length
        else if @get('monitor_format') == "text"
          @get('text_monitors').length
        else
          @get('file_monitors').length
      reminders_count : ->
        @get('reminders').length
      notes_count : ->
        @get('notes').length
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
    show_monitors_panel : ->
      type = @get('monitor_format')
      if type == 'file'
        #file_monitor.set
          #file_monitor : @get('file_monitor')
        $('#file_monitor_modal').modal('show')
      else
        monitors.set
          numeric_monitors : @get('numeric_monitors')
          text_monitors : @get('text_monitors')
          create_monitor_url : @get('create_monitor_url')
          numeric_monitor_explanation : @get('numeric_monitor_explanation')
          monitor_format : @get('monitor_format')
          indicator_id : @get('id')
          source : @
        $("##{type}_monitors_modal").modal('show')
    delete_indicator : (event,obj)->
      data = [{name:'_method', value: 'delete'}]
      url = @get('url')
      $.ajax
        method: 'post'
        url: url
        data: data
        success: @delete_callback
        context: @
    delete_callback : ->
      $(@el).remove()
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
        monitor_format : ""
        id : null
        url : null
      $('#new_indicator_modal').modal('show')

  NatureAllOffences = Ractive.extend
    template : "#nature_all_offences_template"
    components :
      indicator : Indicator
    new_indicator : ->
      $('#new_indicator_modal').modal('show')
      new_indicator.set
        title : ""
        nature : @get('nature')
        offence_id : null
        monitor_format : ""
        id : null
        url : null
      $('#new_indicator_modal').modal('show')

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

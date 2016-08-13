#= require 'jquery_datepicker'
#= require ractive_validator
#= require ractive_local_methods

Ractive.DEBUG = false

$ ->
  FileInput = (node)->
    $(node).on 'change', (event)->
      add_file = (event,el)->
        file = el.files[0]
        ractive = Ractive.getNodeInfo($(el).closest('.fileupload')[0]).ractive
        ractive.add_file(file)
        _reset_input()
      _reset_input = ->
        input = $(node)
        input.wrap('<form></form>').closest('form').get(0).reset()
        input.unwrap()
      add_file(event,@)
    return {
      teardown : ->
        $(node).off 'change'
      update : ->
        #noop
    }

  Ractive.decorators.ractive_fileupload = FileInput

  FileSelectTrigger = (node)->
    $(node).on 'click', (event)->
      UserInput.terminate_user_input_request()
      UserInput.reset()
      $('input:file').trigger('click')
    return {
      teardown : ->
        $(node).off 'click'
      update : ->
        #noop
    }

  Ractive.decorators.file_select_trigger = FileSelectTrigger

  Popover = (node)->
    $(node).popover
      html : true,
      title : ->
        $('#detailsTitle').html()
      content : ->
        data = Ractive.getNodeInfo(@).ractive.get()
        ractive = new Ractive
          template : '#detailsContent'
          data : data
        ractive.toHTML()
      template : $('#popover_template').html()
      trigger: 'hover'
    teardown: ->
      $(node).off('mouseenter')

  EditInPlace = (node,id)->
    @edit = new InpageEdit
      object : @
      on : node
      success : (response, statusText, jqxhr)->
         ractive = @options.object
         @show() # before updating b/c we'll lose the handle
         ractive.set(response)
         advisory_council_minutes_document_uploader.sort()
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : =>
      @edit.off()

  Datepicker = (node)->
    $(node).datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "M d, yy"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          Ractive.getNodeInfo(this).ractive.set('date',selectedDate)
    teardown: ->
      $(node).datepicker( "destroy" )

  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.popover = Popover

  UploadDocument = Ractive.extend
    template : "#upload_template"
    oninit : ->
      @set 'validation_criteria',
        filesize :
          ['lessThan', window.maximum_filesize]
        original_type:
          ['match', window.permitted_filetypes]
      @set
        unconfigured_validation_parameter_error:false
        serialization_key:'advisory_council_minutes'
      @validator = new Validator(@)
      @validate_file() unless @get('persisted')
    validate_file : ->
      @validator.validate_attribute('filesize')
      @validator.validate_attribute('original_type')
    decorators:
      datepicker : Datepicker
    computed :
      persistent_attributes : ->
        ['filesize', 'original_type', 'original_filename', 'lastModifiedDate', 'date']
    cancel_upload : ->
      @parent.remove(@)
    submit : ->
      if @validate()
        data = @formData()
        $.ajax
          # thanks to http://stackoverflow.com/a/22987941/451893
          #xhr: @progress_bar_create.bind(@)
          method : 'post'
          data : data
          url : Routes.nhri_advisory_council_minutes_index_path(current_locale)
          success : @save_upload_document_callback
          context : @
          processData : false
          contentType : false # jQuery correctly sets the contentType and boundary values
    formData : ->
      @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
    save_upload_document_callback : (response,statusText,jqxhr)->
      UserInput.reset()
      @remove_file()
      advisory_council_minutes_document_uploader.unshift('files',response)
    validate : ->
      @validator.validate()
    remove_file : ->
      @parent.remove(@_guid)

  UploadDocuments = Ractive.extend
    template: "{{#upload_documents}}<uploadDocument size='{{size}}' name='{{name}}' lastModifiedDate='{{lastModifiedDate}}' date='{{date}}' />{{/upload_documents}}"
    components:
      uploadDocument : UploadDocument
    remove : (guid)->
      guids = _(@findAllComponents('uploadDocument')).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('upload_documents',index,1)

  Doc = Ractive.extend
    template: '#template-download'
    computed:
      url : ->
        Routes.nhri_advisory_council_minutes_path(current_locale, @get('id'))
    download_file : ->
      window.location = @get('url')
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

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc
    delete : (doc)->
      index = @findAllComponents('doc').indexOf(doc)
      @splice('files',index,1)

  uploader_options =
    el: '#container'
    template : '#uploader_template'
    data:
      files : files
      upload_documents : []
      context : window.context
      _ : _ # use underscore for sorting
    computed :
      empty_upload_documents_list : ->
        @get('upload_documents').length == 0
    components :
      docs : Docs
      uploadDocuments : UploadDocuments
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      attached_document =
        id : null
        file : file
        url : ''
        original_filename : file.name
        filesize : file.size
        original_type : file.type
        lastModifiedDate : file.lastModifiedDate
      @unshift('upload_documents',attached_document)
      @sort()
    start_upload : ->
      flash.notify() if @get('empty_upload_documents_list')
      _(@findAllComponents('uploadDocument')).each (uploadDocument)->
        uploadDocument.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    sort : ->
      new_files = _(@get('files')).sortBy( (f)-> new Date(f.date)).reverse()
      @set('files',new_files)

  window.start_page = ->
    window.advisory_council_minutes_document_uploader = new Ractive uploader_options

  start_page()


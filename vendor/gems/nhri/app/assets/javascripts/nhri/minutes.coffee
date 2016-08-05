//= require 'jquery_datepicker'

Ractive.DEBUG = false

$ ->
  window.fileupload_options =
    permittedFiletypes: window.permitted_filetypes
    maxFileSize: parseInt(window.maximum_filesize)
    failed: (e,data)->
      if data.errorThrown != 'abort'
        alert("The upload failed for some reason")
    prependFiles : false
    filesContainer: '.files'
    downloadTemplateId: '#template-download'
    uploadTemplateContainerId: '#uploads'
    fileInput: '#primary_fileinput'
    replaceFileInput: true
    url : 'minutes.json',
    paramName : 'advisory_council_minutes[file]',
    uploadTemplateId : '#upload_template' 
    uploadTemplate : Ractive.parse($('#upload_template').html())
    done: (e, data)->
      if e.isDefaultPrevented()
          return false
      # 'this' is the upload form
      # $this.data is a jQuery widget
      that = $(@).data('blueimp-fileupload') || $(@).data('fileupload')
      current_locale = that.options.current_locale()
      getFilesFromResponse = data.getFilesFromResponse || that.options.getFilesFromResponse
      file = data.result
      ractive = Ractive.getNodeInfo(@).ractive # it's the ractive instance
      ractive.add_file(file)
      upload_file = Ractive.getNodeInfo(data.context[0]).ractive
      upload_file.parent.remove_upload_file(upload_file._guid)
      that._trigger('completed', e, data)
      that._trigger('finished', e, data)
    add : (e, data) ->
      if e.isDefaultPrevented()
        return false
      $this = $(@)
      that = $this.data('blueimp-fileupload') or $this.data('fileupload')
      _(data.files).each (file)->
        file_attrs =
          lastModifiedDate: file.lastModifiedDate
          name : file.name
          size: file.size
          type: file.type
          fileupload: data
        advisory_council_minutes_document_uploader.
          unshift('upload_files', file_attrs).
          then(
            new_upload = advisory_council_minutes_document_uploader.findAllComponents('uploadfile')[0] # the uploadfile ractive instance
            data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
            data.context.addClass('in')
            new_upload.validate_file_constraints()
          )
      return

  PrimaryFileUpload = (node)->
    $(node).fileupload _.extend({}, fileupload_options)
    teardown : ->
      id = Ractive.getNodeInfo(node).ractive.get('id')
      $(node).fileupload "destroy"
      $(node).fileupload _.extend({}, fileupload_options)
    update : ->
      id = Ractive.getNodeInfo(node).ractive.get('id')
      $(node).fileupload "destroy"
      $(node).fileupload _.extend({}, fileupload_options)

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
  Ractive.decorators.primary_fileupload = PrimaryFileUpload # for the archive file upload
  Ractive.decorators.popover = Popover

  AdvisoryCouncilMinutesValidation =
    validate_file_constraints : -> # the attributes that are checked when a file is added
      extension = @get('name').split('.').pop()
      @set('unconfigured_filetypes_error', permitted_filetypes.length == 0)
      @set('filetype_error', permitted_filetypes.indexOf(extension) == -1)
      @set('filesize_error', @get('size') > maximum_filesize)
      !@get('filetype_error') && !@get('filesize_error') && !@get('unconfigured_filetypes_error')

  UploadFile = Ractive.extend
    template : "#upload_template"
    decorators:
      datepicker : Datepicker
    computed :
      formData : ->
        [ {name : 'advisory_council_minutes[filesize]', value : @get('size')}
          {name : 'advisory_council_minutes[original_type]', value : @get('type')}
          {name : 'advisory_council_minutes[original_filename]', value : @get('name')}
          {name : 'advisory_council_minutes[lastModifiedDate]', value : @get('lastModifiedDate')}
          {name : 'advisory_council_minutes[date]', value : @get('date')}
        ]
    cancel_upload : ->
      @parent.remove(@)
    submit : ->
      if @validate_file_constraints()
        @get('fileupload').formData = @get('formData')
        @get('fileupload').submit()
  , AdvisoryCouncilMinutesValidation

  UploadFiles = Ractive.extend
    template: "{{#upload_files}}<uploadfile size='{{size}}' name='{{name}}' lastModifiedDate='{{lastModifiedDate}}' date='{{date}}' />{{/upload_files}}"
    components:
      uploadfile : UploadFile
    remove : (uploadfile)->
      index = _(@findAllComponents(uploadfile)).indexOf(uploadfile)
      @splice('upload_files',index,1)
    remove_upload_file : (upload_file_guid)->
      guids = _(@findAllComponents('uploadfile')).map('_guid')
      index = _(guids).indexOf(upload_file_guid)
      @splice('upload_files',index,1)

  Doc = Ractive.extend
    template: '#template-download'
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
  , AdvisoryCouncilMinutesValidation

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
      upload_files : []
      context : window.context
      _ : _ # use underscore for sorting
    computed :
      empty_upload_files_list : ->
        @get('upload_files').length == 0
    components :
      docs : Docs
      uploadfiles : UploadFiles
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      @unshift('files',file)
      @sort()
    start_upload : ->
      flash.notify() if @get('empty_upload_files_list')
      _(@findAllComponents('uploadfile')).each (uploadfile)->
        uploadfile.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    sort : ->
      new_files = _(@get('files')).sortBy( (f)-> new Date(f.date)).reverse()
      @set('files',new_files)

  window.start_page = ->
    window.advisory_council_minutes_document_uploader = new Ractive uploader_options

  start_page()

  # this is a hack to workaround a jquery-fileupload-ui bug
  # that causes multiple cancel events, due to multiple event
  # handlers being attached
  #$('#uploads').on 'click', 'i.cancel', (event)->
    #event.preventDefault()
    #template = $(event.currentTarget).closest('.template-upload,.template-download')
    #data = template.data('data') || {}
    #data.context = data.context || template
    #if data.abort
      #data.abort()
    #else
      #data.errorThrown = 'abort'
      ##this._trigger('fail', event, data)
      #$(@).closest('.fileupload').data('blueimp-fileupload').options.fail(event)

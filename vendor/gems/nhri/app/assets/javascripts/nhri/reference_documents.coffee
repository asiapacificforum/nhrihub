# component hierarchy
# icc_reference_document_uploader template: #uploader_template (includes primary_fileupload decorator)
#   docs                     template: #files
#     doc                    template: #template-download (contains document_template as a partial)
#         uploadfiles
#           uploadfile
#   uploadfiles
#     uploadfile
#
Ractive.DEBUG = false

$ ->

  # these options apply to the primary fileupload
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
    #replaceFileInput: false # this doesn't seem to cause any problem, and it solves problems caused by replacing the file input!
    replaceFileInput: true
    url : 'icc_reference_documents.json',
    paramName : 'icc_reference_document[file]',
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
      file = data.result.file
      ractive = Ractive.getNodeInfo(@).ractive # it's the icc_reference_documents_uploader ractive instance
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
          name : file.name
          size: file.size
          type: file.type
          title: ""
          fileupload: data
          primary : true
        icc_reference_document_uploader.
          unshift('upload_files', file_attrs).
          then(
            new_upload = icc_reference_document_uploader.findAllComponents('uploadfile')[0] # the uploadfile ractive instance
            data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
            data.context.addClass('in')
            new_upload.validate_file_constraints()
          )
      return
    destroy : (event, data) ->
      if event.isDefaultPrevented()
        return false
      ractive = Ractive.getNodeInfo(event.originalEvent.target).ractive
      delete_url = ractive.get('url')
      that = $(event.originalEvent.target).closest('.fileupload').data('blueimpFileupload')
      data = $.extend(data, that.options, ractive.get(), type: 'DELETE')
      removeNode = (resp, stat, jqx) ->
          index = @parent.findAllComponents('doc').indexOf(this)
          @parent.splice 'files', index, 1
      data.url = delete_url
      data.dataType = 'json'
      data.context = ractive
      $.ajax(data).done(removeNode).fail ->
        that._trigger 'destroyfailed', event, data
        return
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

  EditInPlace = (node,id)->
    @edit = new InpageEdit
      on : node
      focus_element : 'input.title'
      object : @
      success : (response, statusText, jqxhr)->
         ractive = @.options.object
         @.show() # before updating b/c we'll lose the handle
         ractive.set(response)
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : =>
      @edit.off()

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

  DocDeleter = (node)->
    $(node).on 'click', (event)->
      ev = $.Event(event)
      context = $(event.target).closest('table.document')
      data = $(event.target).closest('.fileupload').data()
      $(event.target).
        closest('.fileupload').
        fileupload('option','destroy')( ev, $.extend({
                                                    context: context,
                                                    type: 'DELETE'
                                                }, data))
    teardown : ->
      $(node).off 'click'

  Ractive.decorators.primary_fileupload = PrimaryFileUpload
  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  UploadFile = Ractive.extend
    template : "#upload_template"
    computed :
      formData : ->
        [ {name : 'icc_reference_document[title]', value : @get('title')}
          {name : 'icc_reference_document[filesize]', value : @get('size')}
          {name : 'icc_reference_document[original_type]', value : @get('type')}
          {name : 'icc_reference_document[original_filename]', value : @get('name')}
          {name : 'icc_reference_document[source_url]', value : @get('source_url')}
        ]
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
    validate_file_constraints : -> # the attributes that are checked when a file is added
      extension = @get('name').split('.').pop()
      @set('unconfigured_filetypes_error', permitted_filetypes.length == 0)
      @set('filetype_error', permitted_filetypes.indexOf(extension) == -1)
      @set('filesize_error', @get('size') > maximum_filesize)
      !@get('filetype_error') && !@get('filesize_error') && !@get('unconfigured_filetypes_error')
    cancel_upload : ->
      @parent.remove(@)
    duplicated_title_in_this_upload : ->
      false
    duplicated_title_with_existing_file : -> #returns true for duplicate found
      false
    duplicate_primary_file : ->
      @duplicated_title_in_this_upload() || @duplicated_title_with_existing_file()
    submit : ->
      unless @duplicate_primary_file() || !@validate_file_constraints()
        @get('fileupload').formData = @get('formData')
        @get('fileupload').submit()

  UploadFiles = Ractive.extend
    template: "{{#upload_files}}<uploadfile title='{{title}}' size='{{size}}' name='{{name}}' />{{/upload_files}}"
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
    computed :
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      title_edit_permitted : ->
        true
      reminders_count : ->
        @get('reminders').length
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("title_error", false)
    validate : ->
      @_validate_title()
    _validate_title : ->
      @set('title', @get('title').trim())
      if @get('title') == ""
        @set("title_error",true)
        false
      else
        true
    add_file : (file)->
      @set(file)
      $('#reminders_modal').modal('show')
    , Remindable

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc
    docs_without : (doc)->
      _(@findAllComponents('doc')).reject((this_doc)-> this_doc.get('id') == doc.get('id'))

  uploader_options =
    el: '#container'
    template : '#uploader_template'
    data:
      files : files
      upload_files : []
      _ : _ # use underscore for sorting
    components :
      docs : Docs
      uploadfiles : UploadFiles
    computed :
      stripped_titles : ->
        _(@findAllComponents('doc')).map (doc)->doc.get('stripped_title')
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      @unshift('files',file)
    start_upload : ->
      flash.notify()
      _(@findAllComponents('uploadfile')).each (uploadfile)->
        uploadfile.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()

  window.start_page = ->
    window.icc_reference_document_uploader = new Ractive uploader_options

  start_page()

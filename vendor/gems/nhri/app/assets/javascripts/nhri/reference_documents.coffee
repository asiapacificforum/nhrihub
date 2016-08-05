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

  #DocDeleter = (node)->
    #$(node).on 'click', (event)->
      #ev = $.Event(event)
      #context = $(event.target).closest('table.document')
      #data = $(event.target).closest('.fileupload').data()
      #$(event.target).
        #closest('.fileupload').
        #fileupload('option','destroy')( ev, $.extend({
                                                    #context: context,
                                                    #type: 'DELETE'
                                                #}, data))
    #teardown : ->
      #$(node).off 'click'

  #Ractive.decorators.primary_fileupload = PrimaryFileUpload
  Ractive.decorators.inpage_edit = EditInPlace
  #Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  UploadDocument = Ractive.extend
    template : "#upload_document_template"
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
    submit : ->
      unless !@validate_file_constraints()
        @get('fileupload').formData = @get('formData')
        @get('fileupload').submit()

  UploadDocuments = Ractive.extend
    template: "#upload_documents_template"
    components:
      uploadDocument : UploadDocument
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
      upload_documents : []
      _ : _ # use underscore for sorting
    components :
      docs : Docs
      uploadDocuments : UploadDocuments
    computed :
      stripped_titles : ->
        _(@findAllComponents('doc')).map (doc)->doc.get('stripped_title')
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      attached_document =
        id : null
        file : file
        title: ''
        file_id : ''
        url : ''
        original_filename : file.name
        filesize : file.size
        original_type : file.type
        document_group_id : @get('document_group_id')
        revision : null
      icc_reference_document_uploader.unshift('upload_documents', attached_document)
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

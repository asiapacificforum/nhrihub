#= require user_input_manager
#= require in_page_edit
#= require ractive_validator
#= require ractive_local_methods
#= require flash
#= require 'confirm_delete_modal'
#= require 'remindable'

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

  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.popover = Popover

  UploadDocument = Ractive.extend
    template : "#upload_document_template"
    oninit : ->
      @set 'validation_criteria',
        filesize :
          ['lessThan', window.maximum_filesize]
        original_type:
          ['match', window.permitted_filetypes]
        title : ['notBlank', {if : =>@get('icc_context')}]
      @set
        unconfigured_validation_parameter_error:false
        serialization_key:'icc_reference_document'
        title_error: false
        duplicate_title_error: false
        duplicate_icc_title_error: false
      @validator = new Validator(@)
      @validate_file() unless @get('persisted')
    validate_file : ->
      @validator.validate_attribute('filesize')
      @validator.validate_attribute('original_type')
    computed :
      persisted : ->
        !_.isNull(@get('id'))
      persistent_attributes : ->
        ['title', 'file', 'original_filename', 'original_type', 'lastModifiedDate', 'filesize', 'user_id', 'source_url'] unless @get('persisted')
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      unconfigured_filetypes_error : ->
        @get('unconfigured_validation_parameter_error')
    formData : ->
      @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
    cancel_upload : ->
      @parent.remove(@)
    submit : ->
      @save_upload_document()
    save_upload_document: ->
      if @validate()
        data = @formData()
        $.ajax
          # thanks to http://stackoverflow.com/a/22987941/451893
          #xhr: @progress_bar_create.bind(@)
          method : 'post'
          data : data
          url : Routes.nhri_icc_reference_documents_path(current_locale)
          success : @save_upload_document_callback
          context : @
          processData : false
          contentType : false # jQuery correctly sets the contentType and boundary values
    formData : ->
      @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
    save_upload_document_callback : (response, status, jqxhr)->
      UserInput.reset()
      @remove_file()
      icc_reference_document_uploader.unshift('files',response.file)
    remove_file : ->
      @parent.remove(@_guid)
    validate : ->
      @validator.validate()

  UploadDocuments = Ractive.extend
    template: "#upload_documents_template"
    components:
      uploadDocument : UploadDocument
    remove : (guid)->
      guids = _(@findAllComponents('uploadDocument')).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('upload_documents',index,1)

  Doc = Ractive.extend
    template: '#template-download'
    computed :
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      title_edit_permitted : ->
        true
      reminders_count : ->
        @get('reminders').length
      url : ->
        Routes.nhri_icc_reference_document_path(current_locale, @get('id'))
      truncated_source_url : ->
        [prefix, path] = @get('source_url').split('//')
        truncated_path = path.split('/')[0]
        if truncated_path == path
          "#{prefix}//#{path}"
        else
          "#{prefix}//#{path}..."
      truncated_title : ->
        @get('title').split(' ').slice(0,4).join(' ')+"..."
      delete_confirmation_message : ->
        "#{delete_confirmation_message} \"#{@get('truncated_title')}\"?"
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
    delete_callback : (data,textStatus,jqxhr)->
      @parent.remove(@get('id'))
  , Remindable, ConfirmDeleteModal

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc
    docs_without : (doc)->
      _(@findAllComponents('doc')).reject((this_doc)-> this_doc.get('id') == doc.get('id'))
    remove : (id)->
      indexes = _(@findAllComponents('doc')).map((doc)->doc.get('id'))
      index_to_remove = indexes.indexOf(id)
      @splice('files',index_to_remove,1)

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
      empty_upload_files_list : ->
        @get('upload_documents').length == 0
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      attached_document =
        id : null
        file : file
        title: ''
        url : ''
        original_filename : file.name
        filesize : file.size
        original_type : file.type
        lastModifiedDate : file.lastModifiedDate
      icc_reference_document_uploader.unshift('upload_documents', attached_document)
    start_upload : ->
      flash.notify() if @get('empty_upload_files_list')
      _(@findAllComponents('uploadDocument')).each (upload_document)->
        upload_document.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    cancel_all : ->
      @flash_hide()
      @set('upload_documents',[])

  window.start_page = ->
    window.icc_reference_document_uploader = new Ractive uploader_options

  start_page()

#= require ractive_validator
#= require ractive_local_methods
#= require 'flash'
#= require 'in_page_edit'
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
      focus_element : 'input.revision'
      success : (response, statusText, jqxhr)->
         ractive = @options.object
         @show() # before updating b/c we'll lose the handle
         ractive.set(response)
         terms_of_reference_document_uploader.sort()
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : =>
      @edit.off()

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
        unique_revision: =>
          upload_documents = @parent.documents_except(@_guid)
          persisted_documents = terms_of_reference_document_uploader.findAllComponents('doc')
          duplicate = _(_(upload_documents).union(persisted_documents)).any (doc)=> doc.get('revision') == @get('revision')
          !duplicate
        revision_format: =>
          re = new RegExp((/^\s*$|\d+\.\d+/))
          re.test(@get('revision'))
      @set
        unconfigured_validation_parameter_error:false
        serialization_key:'terms_of_reference_version'
        revision_format_error : false
        unique_revision_error : false
      @validator = new Validator(@)
      @validate_file() unless @get('persisted')
    validate_file : ->
      @validator.validate_attribute('filesize')
      @validator.validate_attribute('original_type')
    computed :
      persisted : ->
        !_.isNull(@get('id'))
      persistent_attributes : ->
        ['revision', 'filesize', 'original_type', 'original_filename', 'lastModifiedDate'] unless @get('persisted')
    cancel_upload : ->
      @parent.remove(@)
    validate : ->
      @validator.validate()
    submit : ->
      if @validate()
        data = @formData()
        $.ajax
          # thanks to http://stackoverflow.com/a/22987941/451893
          #xhr: @progress_bar_create.bind(@)
          method : 'post'
          data : data
          url : Routes.nhri_advisory_council_terms_of_references_path(current_locale)
          success : @save_upload_document_callback
          context : @
          processData : false
          contentType : false # jQuery correctly sets the contentType and boundary values
    formData : ->
      @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
    save_upload_document_callback : (response,statusText,jqxhr)->
      UserInput.reset()
      @remove_file()
      terms_of_reference_document_uploader.unshift('files',response)
      terms_of_reference_document_uploader.sort()
    remove_file : ->
      @parent.remove(@_guid)

  UploadDocuments = Ractive.extend
    template: "#upload_documents_template"
    components:
      uploadDocument : UploadDocument
    remove : (guid)->
      guids = _(@findAllComponents('uploadDocument')).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('upload_documents',index,1)
    remove_upload_file : (upload_file_guid)->
      guids = _(@findAllComponents('uploadDocument')).map('_guid')
      index = _(guids).indexOf(upload_file_guid)
      @splice('upload_documents',index,1)
    documents_except : (guid)->
      _(@findAllComponents('uploadDocument')).reject((doc)-> doc["_guid"] == guid)

  Doc = Ractive.extend
    template: '#template-download'
    oninit : ->
      @set 'validation_criteria',
        unique_revision: =>
          persisted_documents = _(terms_of_reference_document_uploader.findAllComponents('doc')).
                                   reject (doc)=> doc.get('id') == @get('id')
          duplicate = _(persisted_documents).any (doc)=> doc.get('revision') == @get('revision')
          !duplicate
        revision_format: =>
          re = new RegExp((/^\s*$|\d+\.\d+/))
          re.test(@get('revision'))
      @validator = new Validator(@)
    computed :
      url : -> Routes.nhri_advisory_council_terms_of_reference_path(current_locale,@get('id'))
      delete_confirmation_message : ->
        "#{delete_confirmation_message} \"#{@get('title')}\"?"
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("unique_revision_error", false)
      @set("revision_format_error", false)
    validate : ->
      @validator.validate_attribute('revision_format') && @validator.validate_attribute('unique_revision')
    delete_callback : (data,textStatus,jqxhr)->
      @parent.delete(@)
  , ConfirmDeleteModal

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
      empty_upload_files_list : ->
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
      terms_of_reference_document_uploader.unshift('upload_documents', attached_document)
    start_upload : ->
      flash.notify() if @get('empty_upload_files_list')
      _(@findAllComponents('uploadDocument')).each (upload_document)->
        upload_document.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    sort : ->
      new_files = _(@get('files')).sortBy (f)-> -parseFloat(f.revision)
      @set('files',new_files)
    all_revisions_except : (doc)->
      _(@findAllComponents('doc')).map (this_doc)->
        this_doc.get('revision') unless this_doc.get('id') == doc.get('id')
    sort : ->
      sorted_files = _(@get('files')).sortBy (file)=> parseFloat(file.revision)
      @set('files',sorted_files.reverse())

  window.start_page = ->
    window.terms_of_reference_document_uploader = new Ractive uploader_options

  start_page()

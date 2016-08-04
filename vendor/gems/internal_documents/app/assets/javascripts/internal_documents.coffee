#= require user_input_manager
#= require in_page_edit
#= require ractive_validator
#= require ractive_local_methods
# component hierarchy
# internal_document_uploader template: #uploader_template (includes primary_fileupload decorator)
#   docs                     template: #files
#     doc                    template: #template-download (contains document_template as a partial)
#       archivedoc           template: #document_template (includes archive_fileupload decorator here)
#         uploadfiles        template: inline (archive files staged for uploading)
#           uploadfile       template: #upload_template
#   uploadfiles              template: inline (primary files staged for uploading)
#     uploadfile             template: #upload_template
#
Ractive.DEBUG = false

$ ->
  FileInput = (node)->
    $(node).on 'change', (event)->
      add_file(event,@)
    #$(node).closest('.fileupload').find('.fileinput-button').on 'click', (event)->
      #$(@).parent().find('input:file').trigger('click')
    add_file = (event,el)->
      file = el.files[0]
      ractive = Ractive.getNodeInfo($(el).closest('.fileupload')[0]).ractive
      ractive.add_file(file)
      _reset_input()
    _reset_input = ->
      # this technique comes from jQuery.fileupload does'nt work well with ractive
      input = $(node)
      #inputClone = input.clone(true)
      # make a form and reset it. A hack to reset the fileinput element
      #$('<form></form>').append(inputClone)[0].reset()
      # Detaching allows to insert the fileInput on another form
      # without losing the file input value:
      # detaches the original fileInput and leaves the clone in the DOM
      #input.after(inputClone).detach()
      # Avoid memory leaks with the detached file input:
      #$.cleanData input.unbind('remove')
      input.wrap('<form></form>').closest('form').get(0).reset()
      input.unwrap()
    return {
      teardown : ->
        $(node).off 'change'
      update : ->
        #noop
    }

  Ractive.decorators.ractive_fileupload = FileInput

  FileSelectTrigger = (node)->
    $(node).on 'click', (event)->
      source = Ractive.getNodeInfo(@).ractive # might be an archive doc (has document_group_id) or primary doc (no document_group_id)
      internal_document_uploader.findComponent('uploadDocuments').set('document_group_id', source.get('document_group_id'))
      $('input:file').trigger('click')
    return {
      teardown : ->
        $(node).closest('.fileupload').find('.fileinput-button').off 'click'
      update : ->
        #noop
    }

  Ractive.decorators.file_select_trigger = FileSelectTrigger

  # these options apply to the primary fileupload
  #window.fileupload_options =
    #permittedFiletypes: window.permitted_filetypes
    #maxFileSize: parseInt(window.maximum_filesize)
    #failed: (e,data)->
      #if data.errorThrown != 'abort'
        #alert("The upload failed for some reason")
    #prependFiles : false
    #filesContainer: '.files'
    #downloadTemplateId: '#template-download'
    #uploadTemplateContainerId: '#uploads'
    #fileInput: '#primary_fileinput'
    #replaceFileInput: true
    #url : Routes.internal_documents_path(current_locale) # for #create action
    #paramName : 'internal_document[file]',
    #uploadTemplateId : '#upload_template' 
    #uploadTemplate : Ractive.parse($('#upload_template').html())
    #done: (e, data)->
      #if e.isDefaultPrevented()
          #return false
      ## 'this' is the upload form
      ## $this.data is a jQuery widget
      #that = $(@).data('blueimp-fileupload') || $(@).data('fileupload')
      #current_locale = that.options.current_locale()
      #getFilesFromResponse = data.getFilesFromResponse || that.options.getFilesFromResponse
      #file = data.result.file
      #window.required_files_titles = data.result.required_files_titles
      #ractive = Ractive.getNodeInfo(@).ractive # it's the internal_documents_uploader ractive instance
      #ractive.add_file(file)
      #upload_file = Ractive.getNodeInfo(data.context[0]).ractive
      #upload_file.parent.remove_upload_file(upload_file._guid)
      #that._trigger('completed', e, data)
      #that._trigger('finished', e, data)
    #add : (e, data) ->
      #if e.isDefaultPrevented()
        #return false
      #$this = $(@)
      #that = $this.data('blueimp-fileupload') or $this.data('fileupload')
      #_(data.files).each (file)->
        #file_attrs =
          #lastModifiedDate: file.lastModifiedDate
          #name : file.name
          #size: file.size
          #original_type: file.type
          #title: ""
          #revision: ""
          #document_group_id: ""
          #fileupload: data
          #primary : true
          #context : context
          #type : type
        #internal_document_uploader.
          #unshift('upload_files', file_attrs).
          #then(
            #new_upload = internal_document_uploader.findAllComponents('uploadfile')[0] # the uploadfile ractive instance
            ##new_upload.set('fileupload', data) # so ractive can configure/control upload with data.submit()
            ##new_upload.set('document_group_id', "")
            #data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
            ##$this.fileupload('option', 'formData', ->new_upload.get('formData')) # pass formData from ractive instance to jquery fileupload
            ## using the jquery.fileupload animation, based on the .fade class,
            ## better to use ractive easing TODO
            ##that._transition(data.context) # make the DOM node appear on the page
            #data.context.addClass('in')
            #new_upload.validate_file_constraints()
          #)
      #return

  #ArchiveFileUpload = (node, id, type)->
    #archive_options =
      #add : (e, data) ->
        #if e.isDefaultPrevented()
          #return false
        #$this = $(this)
        #document_group_id = $this.data('document_group_id')
        #that = $this.data('blueimp-fileupload') or $this.data('fileupload')
        #_(data.files).each (file)->
          #file_attrs =
            #lastModifiedDate: file.lastModifiedDate
            #name : file.name
            #size: file.size
            #original_type: file.type
            #title: ""
            #revision: ""
            #fileupload : data
            #document_group_id : document_group_id
            #primary : false
          #internal_document_uploader.
            #unshift('upload_files', file_attrs).
            #then(
              #new_upload = internal_document_uploader.findAllComponents('uploadfile')[0]
              #data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
              ##form_data = _.clone((->new_upload.get('formData'))())
              #$this.fileupload('option', 'formData', ->new_upload.get('formData')) # pass formData from ractive instance to jquery fileupload
              #data.context.addClass('in') # use bootstrap's fade animation
              #new_upload.validate_file_constraints()
            #)
        #data.context.find('.start').prop 'disabled', false
        #data.context.removeClass('processing')
        #return
    #$(node).fileupload _.extend({}, fileupload_options, archive_options)
    #teardown : ->
      #id = Ractive.getNodeInfo(node).ractive.get('id')
      #$(node).fileupload "destroy"
    #update : ( new_id, new_document_group_id)->
      #id = new_id
      #document_group_id = new_document_group_id
      #$("#upload#{new_id}").find('.fileupload').fileupload _.extend({}, fileupload_options, archive_options)

  #PrimaryFileUpload = (node)->
    #$(node).fileupload _.extend({}, fileupload_options)
    #teardown : ->
      #id = Ractive.getNodeInfo(node).ractive.get('id')
      #$(node).fileupload "destroy"
      #$(node).fileupload _.extend({}, fileupload_options)
    #update : ->
      #id = Ractive.getNodeInfo(node).ractive.get('id')
      #$(node).fileupload "destroy"
      #$(node).fileupload _.extend({}, fileupload_options)

  Persistence =
    #delete_complaint : (event)->
      #data = {'_method' : 'delete'}
      #url = Routes.complaint_path(current_locale, @get('id'))
      ## TODO if confirm
      #$.ajax
        #method : 'post'
        #url : url
        #data : data
        #success : @delete_callback
        #dataType : 'json'
        #context : @
    #delete_callback : (data,textStatus,jqxhr)->
      #@parent.remove(@_guid)
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
          url : Routes.internal_documents_path(current_locale)
          success : @save_upload_document_callback
          context : @
          processData : false
          contentType : false # jQuery correctly sets the contentType and boundary values
    formData : ->
      @asFormData @get('persistent_attributes') # in ractive_local_methods, returns a FormData instance
    save_upload_document_callback : (response, status, jqxhr)->
      #UserInput.reset()
      @remove_file()
      if response.file.archive_files.length == 0
        internal_document_uploader.unshift('files',response.file)
      else
        internal_document_uploader.replace(response.file)
    #progress_bar_create : ->
      #@findComponent('progressBar').start()
    #update_persist : (success, error, context) -> # called by EditInPlace
      #if @validate()
        #data = @formData()
        #$.ajax
          ## thanks to http://stackoverflow.com/a/22987941/451893
          #xhr: @progress_bar_create.bind(@)
          #method : 'put'
          #data : data
          #url : Routes.complaint_path(current_locale, @get('id'))
          #success : success
          #context : context
          #processData : false
          #contentType : false # jQuery correctly sets the contentType and boundary values

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
        serialization_key:'internal_document'
        document_group_id: @parent.get('document_group_id')
      @validator = new Validator(@)
      @validate_file() unless @get('persisted')
    validate_file : ->
      @validator.validate_attribute('filesize')
      @validator.validate_attribute('original_type')
    computed :
      persistent_attributes : ->
        ['title', 'original_filename', 'filesize', 'lastModifiedDate', 'file', 'original_type', 'type', 'document_group_id', 'revision'] unless @get('persisted')
      unconfigured_filetypes_error : ->
        @get('unconfigured_validation_parameter_error')
      persisted : ->
        !_.isNull(@get('id'))
      url : ->
        Routes[@get('parent_type')+"_document_path"](current_locale,@get('id'))
      unassigned_titles : ->
        _(required_files_titles).select (title)-> title.empty
      icc_context : ->
        context == 'icc'
    remove_file : ->
      @parent.remove(@_guid)
    delete_document : ->
      data = {'_method' : 'delete'}
      # TODO if confirm
      $.ajax
        method : 'post'
        url : @get('url')
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      @parent.remove(@_guid)
    download_attachment : ->
      window.location = @get('url')
    validate : ->
      @validator.validate()
    cancel_upload : ->
      @parent.remove(@_guid)
    validate_icc_title : ->
      @validator.validate_attribute('title')
    , Persistence

  UploadDocuments = Ractive.extend
    template : "#upload_documents_template"
    components :
      uploadDocument : UploadDocument
    remove : (guid)->
      guids = _(@findAllComponents('uploadDocument')).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('upload_documents',index,1)

  EditInPlace = (node,id)->
    edit = new InpageEdit
      object : @
      on : node
      focus_element : 'input.title'
      success : (response, statusText, jqxhr)->
         ractive = @.options.object
         @.show() # before updating b/c we'll lose the handle
         if ractive.findParent('doc') # an archive file was updated
           ractive.parent.set(response)
         else
           ractive.set(response)
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : =>
      edit.off()
    update : =>
      edit.off()

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

  #Ractive.decorators.archive_fileupload = ArchiveFileUpload
  #Ractive.decorators.primary_fileupload = PrimaryFileUpload
  Ractive.decorators.inpage_edit = EditInPlace
  #Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  #UploadFile = Ractive.extend
    #template : "#upload_template"
    #oninit : ->
      #if !_.isNaN(parseInt(@get('document_group_id')))
        #@set('title',@get('icc_title'))
    #computed :
      #formData : ->
        #[ {name : 'internal_document[title]', value : @get('title')}
          #{name : 'internal_document[revision]', value : @get('revision')}
          #{name : 'internal_document[filesize]', value : @get('size')}
          #{name : 'internal_document[original_type]', value : @get('original_type')}
          #{name : 'internal_document[original_filename]', value : @get('name')}
          #{name : 'internal_document[lastModifiedDate]', value : @get('lastModifiedDate')}
          #{name : 'internal_document[document_group_id]', value : @get('document_group_id')}
          #{name : 'internal_document[type]', value : @get('type')}
        #]
      #icc_doc : ->
        #st = @get('stripped_title')
        #id = @get('document_group_id')
        #if !_.isNaN(parseInt(id)) # it's an archive file so see if its document_group_id is one belonging to required files titles
          #_(required_files_titles).find((doc)-> doc.document_group_id == parseInt(id) )
        #else # primary file, so we compare its title with the required files titles
          #_(required_files_titles).find((doc)-> doc.title.replace(/\s/g,"").toLowerCase() == st )
      #is_icc_doc : ->
        #!_.isUndefined(@get('icc_doc'))
      #icc_title : -> # only for archive files being added to an existing icc doc
        #if @get('is_icc_doc')
          #@get('icc_doc').title
        #else
          #""
      #stripped_title : ->
        #@get('title').replace(/\s/g,"").toLowerCase()
      #unassigned_titles : ->
        #_(required_files_titles).select (title)-> title.empty
    #validate_file_constraints : -> # the attributes that are checked when a file is added
      #extension = @get('name').split('.').pop()
      #@set('unconfigured_filetypes_error', permitted_filetypes.length == 0)
      #@set('filetype_error', permitted_filetypes.indexOf(extension) == -1)
      #@set('filesize_error', @get('size') > maximum_filesize)
      #!@get('filetype_error') && !@get('filesize_error') && !@get('unconfigured_filetypes_error')
    #cancel_upload : ->
      #@parent.remove(@)
    #validate_icc_unique : -> # returns false for duplicate files
      #title_matches_a_primary_title = _(internal_document_uploader.get('stripped_titles')).indexOf(@get('stripped_title')) != -1
      #primary_file = @get('primary')
      #@set('duplicate_icc_title_error', title_matches_a_primary_title && primary_file )
      #!@get('duplicate_icc_title_error')
    #validate_pending_icc_unique : (titles)-> # returns true for valid
      #identical_titles = _(titles).filter (title)=> title == @get('stripped_title')
      #@set('duplicate_icc_title_error', identical_titles.length != 1 )# there should be exactly one
      #!@get('duplicate_icc_title_error')
    #is_icc_doc : ->
      #icc_doc = _(internal_document_uploader.get('required_files_titles')).
          #find((doc)=> doc.title.replace(/\s/g,"").toLowerCase() == @get('stripped_title') )
      #!_.isUndefined(icc_doc)
    #duplicated_title_in_this_upload : ->
      #primary_file = _.isEmpty(@get('document_group_id'))
      #unique_this_upload = @parent.validate_pending_icc_unique() # true = valid
      #fileupload = @get('fileupload')
      #fileupload && (primary_file && @is_icc_doc() && !unique_this_upload)
    #duplicated_title_with_existing_file : -> #returns true for duplicate found
      #primary_file = _.isEmpty(@get('document_group_id'))
      #unique = @validate_icc_unique() # false is duplicate, true is unique
      #fileupload = @get('fileupload')
      #fileupload && (primary_file && @is_icc_doc() && !unique)
    #duplicate_icc_primary_file : ->
      #@duplicated_title_in_this_upload() || @duplicated_title_with_existing_file()
    #icc_revision_to_non_icc_primary : ->
      #non_icc_primary = !@get('is_icc_doc')
      #icc_revision = _(required_files_titles).map((doc)-> doc.title.replace(/\s/g,"").toLowerCase()).indexOf(@get('stripped_title')) != -1
      #error = non_icc_primary && icc_revision
      #@set('icc_revision_to_non_icc_primary_error',error)
      #error
    #validate_icc_title : ->
      #icc = context == 'icc'
      #blank_title = _.isEmpty(@get('title')) || (@get('title')=='0')
      #@set('title_error', icc && blank_title)
      #!@get('title_error')
    #submit : ->
      #unless @duplicate_icc_primary_file() || @icc_revision_to_non_icc_primary() || !@validate_file_constraints() || !@validate_icc_title()
        #@get('fileupload').formData = @get('formData')
        #@get('fileupload').submit()

  #UploadFiles = Ractive.extend
    #template: "{{#upload_files}}<uploadfile title='{{title}}' revision='{{revision}}' size='{{size}}' type='{{type}}' name='{{name}}' lastModifiedDate='{{lastModifiedDate}}' document_group_id='{{document_group_id}}' />{{/upload_files}}"
    #components:
      #uploadfile : UploadFile
    #remove : (uploadfile)->
      #index = _(@findAllComponents(uploadfile)).indexOf(uploadfile)
      #@splice('upload_files',index,1)
    #remove_upload_file : (upload_file_guid)->
      #guids = _(@findAllComponents('uploadfile')).map('_guid')
      #index = _(guids).indexOf(upload_file_guid)
      #@splice('upload_files',index,1)
    #validate_pending_icc_unique : -> # returns true if all files are valid by this criterion
      #all_titles = _(@findAllComponents('uploadfile')).map (uploadfile)-> uploadfile.get('stripped_title')
      #files_valid = _(@findAllComponents('uploadfile')).map (uploadfile) -> uploadfile.validate_pending_icc_unique(all_titles)
      #valid_files = _(files_valid).filter((a)->a) # each of the files_valid values should be true
      #valid_files.length == all_titles.length # true for no invalid files

  ArchiveDoc = Ractive.extend
    template: '#document_template'
    oninit : ->
      @remove_errors()
    computed :
      url : -> Routes.internal_document_path(current_locale,@get('id'))
      file : -> false
      archive_file : -> true
      icc_doc : ->
        st = @get('stripped_title')
        _(required_files_titles).find((doc)-> doc.title.replace(/\s/g,"").toLowerCase() == st )
      is_icc_doc : ->
        !_.isUndefined(@get('icc_doc'))
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      non_icc_document_group : ->
        icc_document_group_ids = _(required_files_titles).map (doc)-> doc.document_group_id
        icc_document_group_ids.indexOf(@get('document_group_id')) == -1
      title_edit_permitted : ->
        @get('non_icc_document_group')
      document_group : ->
        @parent.parent
    remove_errors : ->
      @set
        title_error: false
        revision_error: false
        icc_title_error:false
    validate : ->
      @_validate_nonblank_title() && @_validate_non_icc_title() && @_validate_revision()
    _validate_non_icc_title : ->
      has_icc_title = @get('is_icc_doc')
      non_icc_document_group = @get('non_icc_document_group')
      @set('icc_title_error', has_icc_title && non_icc_document_group )
      !@get('icc_title_error')
    _validate_nonblank_title : ->
      @set('title', @get('title').trim())
      @set("title_error", @get('title') == "" )
      !@get('title_error')
    _validate_revision : ->
      @set('revision', @get('revision').trim())
      @set("revision_error", @get('revision') == "")
      !@get('revision_error')
    delete_document : ->
      data = {'_method' : 'delete'}
      url = Routes.internal_document_path(current_locale, @get('id'))
      # TODO if confirm
      $.ajax
        method : 'post'
        url : url
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      # the whole document group is replaced
      @get('document_group').replace(data)

  Doc = Ractive.extend
    template: '#template-download'
    oninit : ->
      @set('archive_upload_files',[])
    computed :
      url : -> Routes.internal_document_path(current_locale,@get('id'))
      file : -> true
      archive_file : -> false
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      title_edit_permitted : ->
        true
    components :
      archivedoc : ArchiveDoc
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("title_error", false)
      @set("revision_error", false)
    validate : ->
      @_validate_title() && @_validate_revision() && @_validate_icc_unique()
    _validate_title : ->
      @set('title', @get('title').trim())
      if @get('title') == ""
        @set("title_error",true)
        false
      else
        true
    _validate_revision : ->
      @set('revision', @get('revision').trim())
      if @get('revision') == ""
        @set("revision_error",true)
        false
      else
        true
    _validate_icc_unique : ->
      if _(@parent.docs_without(@)).map((doc)-> doc.get('stripped_title')).indexOf(@get('stripped_title')) != -1
        @set('duplicate_icc_title_error',true)
        false
      else
        @set('duplicate_icc_title_error',false)
        true
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
        type : "InternalDocument"
        document_group_id : @get('document_group_id')
        revision : null
        #serialization_key : 'complaint[complaint_documents_attributes][]'
      internal_document_uploader.unshift('upload_documents', attached_document)
    delete_document : ->
      data = {'_method' : 'delete'}
      url = Routes.internal_document_path(current_locale, @get('id'))
      # TODO if confirm
      $.ajax
        method : 'post'
        url : url
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      if _.isUndefined(data) # last doc in the group, so nothing returned
        @parent.remove(@)
      else
        @parent.replace(data)

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc
    docs_without : (doc)->
      _(@findAllComponents('doc')).reject((this_doc)-> this_doc.get('id') == doc.get('id'))
    replace : (primary_file)-> # an archive file was added or deleted... replace the document group with the returned primary plus archive files
      what_to_replace = _(@findAllComponents('doc')).find (doc) ->
        doc.get('document_group_id') == primary_file.document_group_id
      index_to_replace = @findAllComponents('doc').indexOf(what_to_replace)
      @splice('files',index_to_replace,1,primary_file)
    remove : (document)->
      what_to_replace = _(@findAllComponents('doc')).find (doc) -> doc.get('document_group_id') == document.get('document_group_id')
      index_to_replace = @findAllComponents('doc').indexOf(what_to_replace)
      @splice('files',index_to_replace,1)

  uploader_options =
    el: '#container'
    template : '#uploader_template'
    data:
      required_files_titles : window.required_files_titles
      files : files
      upload_documents : []
      _ : _ # use underscore for sorting
      context : window.context
      type : window.type
    components :
      docs : Docs
      #uploadfiles : UploadFiles
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
        type : "InternalDocument"
        document_group_id : null
        revision : null
        #serialization_key : 'complaint[complaint_documents_attributes][]'
      @unshift('upload_documents', attached_document)
    start_upload : ->
      flash.notify()
      _(@findAllComponents('uploadDocument')).each (upload_document)->
        upload_document.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    replace : (primary_file)-> # an archive file was added... replace the document group with the returned primary plus archive files
      @findComponent('docs').replace(primary_file)

  window.start_page = ->
    window.internal_document_uploader = new Ractive uploader_options

  start_page()

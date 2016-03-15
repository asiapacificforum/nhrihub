# component hierarchy
# internal_document_uploader template: #uploader_template (includes primary_fileupload decorator)
#   docs                     template: #files
#     doc                    template: #template-download (contains document_template as a partial)
#       archivedoc           template: #document_template (includes archive_fileupload decorator here)
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
    replaceFileInput: true
    url : 'internal_documents.json',
    paramName : 'internal_document[file]',
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
      window.required_files_titles = data.result.required_files_titles
      ractive = Ractive.getNodeInfo(@).ractive # it's the internal_documents_uploader ractive instance
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
          title: ""
          revision: ""
          document_group_id: ""
          fileupload: data
          primary : true
          context : context
        internal_document_uploader.
          unshift('upload_files', file_attrs).
          then(
            new_upload = internal_document_uploader.findAllComponents('uploadfile')[0] # the uploadfile ractive instance
            #new_upload.set('fileupload', data) # so ractive can configure/control upload with data.submit()
            #new_upload.set('document_group_id', "")
            data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
            #$this.fileupload('option', 'formData', ->new_upload.get('formData')) # pass formData from ractive instance to jquery fileupload
            # using the jquery.fileupload animation, based on the .fade class,
            # better to use ractive easing TODO
            #that._transition(data.context) # make the DOM node appear on the page
            data.context.addClass('in')
            new_upload.validate_file_constraints()
          )
      return

  ArchiveFileUpload = (node, id, type)->
    archive_options =
      add : (e, data) ->
        if e.isDefaultPrevented()
          return false
        $this = $(this)
        document_group_id = $this.data('document_group_id')
        that = $this.data('blueimp-fileupload') or $this.data('fileupload')
        _(data.files).each (file)->
          file_attrs =
            lastModifiedDate: file.lastModifiedDate
            name : file.name
            size: file.size
            type: file.type
            title: ""
            revision: ""
            fileupload : data
            document_group_id : document_group_id
            primary : false
          internal_document_uploader.
            unshift('upload_files', file_attrs).
            then(
              new_upload = internal_document_uploader.findAllComponents('uploadfile')[0]
              data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
              #form_data = _.clone((->new_upload.get('formData'))())
              $this.fileupload('option', 'formData', ->new_upload.get('formData')) # pass formData from ractive instance to jquery fileupload
              data.context.addClass('in') # use bootstrap's fade animation
              new_upload.validate_file_constraints()
            )
        data.context.find('.start').prop 'disabled', false
        data.context.removeClass('processing')
        return
    $(node).fileupload _.extend({}, fileupload_options, archive_options)
    teardown : ->
      id = Ractive.getNodeInfo(node).ractive.get('id')
      $(node).fileupload "destroy"
    update : ( new_id, new_document_group_id)->
      id = new_id
      document_group_id = new_document_group_id
      $("#upload#{new_id}").find('.fileupload').fileupload _.extend({}, fileupload_options, archive_options)

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

  Ractive.decorators.archive_fileupload = ArchiveFileUpload
  Ractive.decorators.primary_fileupload = PrimaryFileUpload
  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  UploadFile = Ractive.extend
    template : "#upload_template"
    oninit : ->
      if !_.isNaN(parseInt(@get('document_group_id')))
        @set('title',@get('icc_title'))
    computed :
      formData : ->
        [ {name : 'internal_document[title]', value : @get('title')}
          {name : 'internal_document[revision]', value : @get('revision')}
          {name : 'internal_document[filesize]', value : @get('size')}
          {name : 'internal_document[original_type]', value : @get('type')}
          {name : 'internal_document[original_filename]', value : @get('name')}
          {name : 'internal_document[lastModifiedDate]', value : @get('lastModifiedDate')}
          {name : 'internal_document[document_group_id]', value : @get('document_group_id')}
        ]
      icc_doc : ->
        st = @get('stripped_title')
        id = @get('document_group_id')
        if !_.isNaN(parseInt(id)) # it's an archive file so see if its document_group_id is one belonging to required files titles
          _(required_files_titles).find((doc)-> doc.document_group_id == parseInt(id) )
        else # primary file, so we compare its title with the required files titles
          _(required_files_titles).find((doc)-> doc.title.replace(/\s/g,"").toLowerCase() == st )
      is_icc_doc : ->
        !_.isUndefined(@get('icc_doc'))
      icc_title : -> # only for archive files being added to an existing icc doc
        if @get('is_icc_doc')
          @get('icc_doc').title
        else
          ""
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      unassigned_titles : ->
        _(required_files_titles).select (title)-> title.empty
    validate_file_constraints : -> # the attributes that are checked when a file is added
      extension = @get('name').split('.').pop()
      @set('unconfigured_filetypes_error', permitted_filetypes.length == 0)
      @set('filetype_error', permitted_filetypes.indexOf(extension) == -1)
      @set('filesize_error', @get('size') > maximum_filesize)
      !@get('filetype_error') && !@get('filesize_error') && !@get('unconfigured_filetypes_error')
    cancel_upload : ->
      @parent.remove(@)
    validate_icc_unique : -> # returns false for duplicate files
      title_matches_a_primary_title = _(internal_document_uploader.get('stripped_titles')).indexOf(@get('stripped_title')) != -1
      primary_file = @get('primary')
      if title_matches_a_primary_title && primary_file
        @set('duplicate_icc_title_error',true)
        false
      else
        @set('duplicate_icc_title_error',false)
        true
    validate_pending_icc_unique : (titles)-> # returns true for valid
      identical_titles = _(titles).filter (title)=> title == @get('stripped_title')
      if identical_titles.length != 1 # there should be exactly one
        @set('duplicate_icc_title_error',true)
        false
      else
        @set('duplicate_icc_title_error',false)
        true
    is_icc_doc : ->
      icc_doc = _(internal_document_uploader.get('required_files_titles')).
          find((doc)=> doc.title.replace(/\s/g,"").toLowerCase() == @get('stripped_title') )
      !_.isUndefined(icc_doc)
    duplicated_title_in_this_upload : ->
      primary_file = _.isEmpty(@get('document_group_id'))
      unique_this_upload = @parent.validate_pending_icc_unique() # true = valid
      fileupload = @get('fileupload')
      fileupload && (primary_file && @is_icc_doc() && !unique_this_upload)
    duplicated_title_with_existing_file : -> #returns true for duplicate found
      primary_file = _.isEmpty(@get('document_group_id'))
      unique = @validate_icc_unique() # false is duplicate, true is unique
      fileupload = @get('fileupload')
      fileupload && (primary_file && @is_icc_doc() && !unique)
    duplicate_icc_primary_file : ->
      @duplicated_title_in_this_upload() || @duplicated_title_with_existing_file()
    icc_revision_to_non_icc_primary : ->
      non_icc_primary = !@get('is_icc_doc')
      icc_revision = _(required_files_titles).map((doc)-> doc.title.replace(/\s/g,"").toLowerCase()).indexOf(@get('stripped_title')) != -1
      error = non_icc_primary && icc_revision
      @set('icc_revision_to_non_icc_primary_error',error)
      error
    submit : ->
      unless @duplicate_icc_primary_file() || @icc_revision_to_non_icc_primary() || !@validate_file_constraints()
        @get('fileupload').formData = @get('formData')
        @get('fileupload').submit()

  UploadFiles = Ractive.extend
    template: "{{#upload_files}}<uploadfile context='{{context}}' title='{{title}}' revision='{{revision}}' size='{{size}}' type='{{type}}' name='{{name}}' lastModifiedDate='{{lastModifiedDate}}' document_group_id='{{document_group_id}}' />{{/upload_files}}"
    components:
      uploadfile : UploadFile
    remove : (uploadfile)->
      index = _(@findAllComponents(uploadfile)).indexOf(uploadfile)
      @splice('upload_files',index,1)
    remove_upload_file : (upload_file_guid)->
      guids = _(@findAllComponents('uploadfile')).map('_guid')
      index = _(guids).indexOf(upload_file_guid)
      @splice('upload_files',index,1)
    validate_pending_icc_unique : -> # returns true if all files are valid by this criterion
      all_titles = _(@findAllComponents('uploadfile')).map (uploadfile)-> uploadfile.get('stripped_title')
      files_valid = _(@findAllComponents('uploadfile')).map (uploadfile) -> uploadfile.validate_pending_icc_unique(all_titles)
      valid_files = _(files_valid).filter((a)->a) # each of the files_valid values should be true
      valid_files.length == all_titles.length # true for no invalid files

  ArchiveDoc = Ractive.extend
    template: '#document_template'
    oninit : ->
      @remove_errors()
    computed :
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

  Doc = Ractive.extend
    template: '#template-download'
    oninit : ->
      @set('archive_upload_files',[])
    computed :
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
      @set(file)

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
      required_files_titles : window.required_files_titles
      files : files
      upload_files : []
      context : window.context
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
    window.internal_document_uploader = new Ractive uploader_options

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
  window.replaceFileInput = (input) ->
    inputClone = input.clone(true)
    fileInputClone = inputClone
    $('<form></form>').append(inputClone)[0].reset()
    input.after(inputClone).detach()
    $.cleanData input.unbind('remove')
    input = inputClone
    return

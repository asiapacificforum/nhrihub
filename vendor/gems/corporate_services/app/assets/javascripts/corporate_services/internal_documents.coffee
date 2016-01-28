# component hierarchy
# internal_document_uploader template: #uploader_template (includes primary_fileupload decorator)
#   docs                     template: #files
#     doc                    template: #template-download (contains document_template as a partial)
#       archivedoc           template: #document_template (includes archive_fileupload decorator here)
#
# decorators
# primary_fileupload invokes #primary_upload as its upload template
# archive_fileupload invokes #archive_upload as its upload template
Ractive.DEBUG = false

$ ->
  # these options apply to the primary fileupload
  fileupload_options =
    permittedFiletypes: window.permitted_filetypes
    maxFileSize: parseInt(window.maximum_filesize)
    failed: (e,data)->
      if data.errorThrown != 'abort'
        alert("The upload failed for some reason")
    prependFiles : false
    filesContainer: '.files'
    #formData: ->
      #inputs = @.context.find(':input')
      #arr = inputs.serializeArray()
      #return arr
    downloadTemplateId: '#template-download'
    uploadTemplateContainerId: '#uploads'
    #fileInput: '#primary_fileinput'
    url : 'internal_documents.json',
    paramName : 'internal_document[file]',
    uploadTemplateId : '#primary_upload' 
    done: (e, data)->
      if e.isDefaultPrevented()
          return false
      # 'this' is the upload form
      # $this.data is a jQuery widget
      that = $(@).data('blueimp-fileupload') || $(@).data('fileupload')
      current_locale = that.options.current_locale()
      getFilesFromResponse = data.getFilesFromResponse || that.options.getFilesFromResponse
      file = data.result
      ractive = Ractive.getNodeInfo(@).ractive
      ractive.add_file(file)
      data.context.remove()
      that._trigger('completed', e, data)
      that._trigger('finished', e, data)
    add : (e, data) ->
      if e.isDefaultPrevented()
        return false
      $this = $(this)
      that = $this.data('blueimp-fileupload') or $this.data('fileupload')
      options = that.options
      # options include passed-in options when widget was initialized
      # in initialization script on the index page
      # merged with default options, above
      data.context = that._renderUpload(data.files).data('data', data).addClass('processing')
      #options.uploadTemplateContainer.append data.context
      #that._forceReflow data.context
      ractive = Ractive.getNodeInfo(@).ractive
      ractive.set('fileupload', data) # so ractive can configure/control upload with data.submit()
      # puts the upload template on the page, in the filesContainer
      _(data.files).each (file)->
        ractive.
          # using the jquery.fileupload animation, based on the .fade class,
          # better to use ractive easing TODO
          push('upload_files', _.extend({},file, {prefix : 'internal_document', label_prefix : 'internal_document'})).
          then(
            new_upload = ractive.findAllComponents('uploadfile')[0]
            $this.fileupload('option', 'formData', ->new_upload.get('formData'))
            that._transition($(ractive.findAllComponents('uploadfile')[0].find('*')))
            new_upload.validate_file_constraints()
          )
      data.process(->
        # e.g. validation
        $this.fileupload 'process', data
      ).always(->
        data.context.each((index) ->
          $(this).find('.size').text that._formatFileSize(data.size)
          return
        ).removeClass 'processing'
        return
      ).done(->
        data.context.find('.start').prop 'disabled', false
        return
      ).fail ->
        # e.g. validation fail
        if data.files.error
          data.context.each (index) ->
            error = data.files[index].error
            if error
              $(this).find('.error').text error
              $(this).find('.start').prop 'disabled', true
            return
        return
      return

  ArchiveFileUpload = (node, url, id)->
    archive_options =
      url : url
      type : 'put'
      #fileInput :  "#upload#{id} #archive_fileinput"  # don't know why this doesn't work!
      paramName : 'internal_document[archive_files][][file]'
      uploadTemplateId : '#archive_upload'
      add : (e, data) ->
        if e.isDefaultPrevented()
          return false
        $this = $(this)
        that = $this.data('blueimp-fileupload') or $this.data('fileupload')
        options = that.options
        # options include passed-in options when widget was initialized
        # in initialization script on the index page
        # merged with default options, above
        data.context = that._renderUpload(data.files).data('data', data).addClass('processing')
        #options.uploadTemplateContainer.append data.context
        #that._forceReflow data.context
        ractive = Ractive.getNodeInfo(@).ractive
        ractive.set('fileupload', data) # so ractive can configure/control upload with data.submit()
        # puts the upload template on the page, in the filesContainer
        _(data.files).each (file)->
          ractive.
            # using the jquery.fileupload animation, based on the .fade class,
            # better to use ractive easing TODO
            push('archive_files', _.extend({},file, {prefix : 'internal_document', label_prefix : 'internal_document'})).
            then(
              new_upload = ractive.findAllComponents('uploadfile')[0]
              $this.fileupload('option', 'formData', ->new_upload.get('formData'))
              that._transition($(ractive.findAllComponents('uploadfile')[0].find('*')))
              new_upload.validate_file_constraints()
            )
        data.process(->
          # e.g. validation
          $this.fileupload 'process', data
        ).always(->
          data.context.each((index) ->
            $(this).find('.size').text that._formatFileSize(data.size)
            return
          ).removeClass 'processing'
          return
        ).done(->
          data.context.find('.start').prop 'disabled', false
          return
        ).fail ->
          # e.g. validation fail
          if data.files.error
            data.context.each (index) ->
              error = data.files[index].error
              if error
                $(this).find('.error').text error
                $(this).find('.start').prop 'disabled', true
              return
          return
        return
    $(node).fileupload _.extend({}, fileupload_options, archive_options)
    teardown : ->
      #noop for now

  PrimaryFileUpload = (node)->
    $(node).fileupload _.extend({}, fileupload_options)
    teardown : ->
      #noop for now

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
    teardown : ->
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

  Ractive.decorators.archive_fileupload = ArchiveFileUpload # for the archive file upload
  Ractive.decorators.primary_fileupload = PrimaryFileUpload # for the archive file upload
  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  ArchiveDoc = Ractive.extend
    template: '#document_template'
    computed :
      file : -> false
      archive_file : -> true
    remove_errors : ->
      @set("title_error", false)
      @set("revision_error", false)
    validate : ->
      @_validate_title() && @_validate_revision()
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

  Doc = Ractive.extend
    template: '#template-download'
    computed :
      file : -> true
      archive_file : -> false
    components :
      archivedoc : ArchiveDoc
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("title_error", false)
      @set("revision_error", false)
    validate : ->
      @_validate_title() && @_validate_revision()
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
    add_file : (file)->
      @set(file)

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc

  UploadFile = Ractive.extend
    template : "#pa_upload"
    computed :
      formData : ->
        [
          {name : 'internal_document[title]', value : @get('title')},
          {name : 'internal_document[revision]', value : @get('revision')},
          {name : 'internal_document[filesize]', value : @get('size')},
          {name : 'internal_document[original_type]', value : @get('type')},
          {name : 'internal_document[original_filename]', value : @get('name')},
          {name : 'internal_document[lastModifiedDate]', value : @get('lastModifiedDate')}
        ]
    validate_file_constraints : ->
      extension = @get('name').split('.').pop()
      if permitted_filetypes.indexOf(extension) == -1
        @set('filetype_error', true)
      else
        @set('filetype_error', false)
      if @get('size') > maximum_filesize
        @set('filesize_error', true)
      else
        @set('filesize_error', false)
      !@get('filetype_error') && !@get('filesize_error')
    cancel_upload : ->
      @parent.remove(@)

  UploadFiles = Ractive.extend
    template: '{{#upload_files}}<uploadfile>{{/upload_files}}'
    components:
      uploadfile : UploadFile
    remove : (uploadfile)->
      index = _(@findAllComponents(uploadfile)).indexOf(uploadfile)
      @splice('upload_files',index,1)

  window.internal_document_uploader = new Ractive
    el: '#container'
    template : '#uploader_template'
    data:
      required_files_titles : window.required_files_titles 
      files : files
      upload_files : []
      _ : _ # use underscore for sorting
    components :
      docs : Docs
      uploadfiles : UploadFiles
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      @push('files',file)
    start_upload : ->
      flash.notify()
      if !_.isUndefined(@get('fileupload'))
        @get('fileupload').submit() # handled by jquery-fileupload
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()


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

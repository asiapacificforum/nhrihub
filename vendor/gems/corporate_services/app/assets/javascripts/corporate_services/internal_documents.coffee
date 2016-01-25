Ractive.DEBUG = false

$ ->
  # these options apply to the primary fileupload
  fileupload_options =
    permittedFiletypes: permitted_filetypes,
    maxFileSize: parseInt(maximum_filesize),
    failed: (e,data)->
      if data.errorThrown != 'abort'
        alert("The upload failed for some reason")
    prependFiles : false
    filesContainer: '.files'
    formData: ->
      inputs = @.context.find(':input')
      arr = inputs.serializeArray()
      return arr
    downloadTemplateId: '#template-download'
    uploadTemplateContainerId: '#uploads'
    #fileInput: '#primary_fileinput'
    url : 'internal_documents.json',
    paramName : 'internal_document[file]',
    uploadTemplateId : '#primary_upload' 

  ArchiveFileUpload = (node, url, id)->
    archive_options =
      url : url
      type : 'put'
      #fileInput :  "#upload#{id} #archive_fileinput"  # don't know why this doesn't work!
      paramName : 'internal_document[archive_files][][file]'
      uploadTemplateId : '#archive_upload'
    $(node).fileupload _.extend({}, fileupload_options, archive_options)
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

  window.internal_documents = new Ractive
                          el: '.files'
                          template: '#files'
                          data:
                            required_files_titles : required_files_titles 
                            files : files
                            _ : _ # use underscore for sorting
                          components:
                            doc : Doc

  # initialize the buttonbar with fileupload widget
  # contains .start, .cancel and .fileinput-button buttons
  $('.fileupload.buttonbar').fileupload(_.extend({},fileupload_options))


  # this is a hack to workaround a jquery-fileupload-ui bug
  # that causes multiple cancel events, due to multiple event
  # handlers being attached
  $('#uploads').on 'click', 'i.cancel', (event)->
    event.preventDefault()
    template = $(event.currentTarget).closest('.template-upload,.template-download')
    data = template.data('data') || {}
    data.context = data.context || template
    if data.abort
      data.abort()
    else
      data.errorThrown = 'abort'
      this._trigger('fail', event, data)

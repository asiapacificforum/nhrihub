#= require user_input_manager
#= require in_page_edit
#= require ractive_validator
#= require ractive_local_methods
#= require confirm_delete_modal

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
      source = Ractive.getNodeInfo(@).ractive # might be an archive doc (has document_group_id) or primary doc (no document_group_id)
      internal_document_uploader.findComponent('uploadDocuments').set('document_group_id', source.get('document_group_id'))
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

  Persistence =
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
      UserInput.reset()
      @remove_file()
      if response.file.archive_files.length == 0
        internal_document_uploader.unshift('files',response.file)
      else
        internal_document_uploader.replace(response.file)

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
      if @get('is_icc_doc')
        document_group = _(required_files_titles).find (req_doc)=>req_doc.document_group_id == @get('document_group_id')
        @set('title',document_group.title)
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
      is_icc_doc : -> # see if a document is being added to an icc required document group
        document_group_id = @get('document_group_id')
        required_document_ids = _(required_files_titles).pluck('document_group_id')
        _(required_document_ids).any (id)-> id == document_group_id
    remove_file : ->
      @parent.remove(@_guid)
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

  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.popover = Popover

  ArchiveDoc = Ractive.extend
    template: '#document_template'
    oninit : ->
      @set
        validation_criteria :
          icc_title : =>
            return true if !@get('has_icc_title')
            match_parent = @get('title') == @parent.get('title')
            return true if match_parent
      @remove_errors()
      @validator = new Validator(@)
    onconfig : ->
      @inclusionMatcher = new InclusionMatcher(@)
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
      has_icc_title : ->
        icc_titles = _(@get('required_files_titles')).pluck('title')
        _(icc_titles).any (title)=>
          re = new RegExp(title)
          re.test @get('title')
      delete_confirmation_message : ->
        i18n.delete_confirmation_message
      include : -> @inclusionMatcher.include()
      inclusion_criteria : ->
        title : "asText"
        filetype : "matchAny"
    remove_errors : ->
      @set
        title_error: false
        revision_error: false
        icc_title_error:false
    delete_callback : (data,textStatus,jqxhr)->
      # the whole document group is replaced
      @get('document_group').replace(data)
    validate : ->
      @validator.validate()
    include : ->
      false
    download_file : ->
      window.location = @get('url')
  , ConfirmDeleteModal

  class InclusionMatcher
    constructor : (item)->
      if typeof item != 'object'
        throw new Error "No ractive object has been provided to InclusionMatcher"
      @item = item
    inclusion_criteria : ->
      @item.get('inclusion_criteria')
    include : ->
      attributes = _(@inclusion_criteria()).keys()
      _(attributes).any (attribute)=> @filterMatchAttribute(attribute)
    filterMatchAttribute : (attribute)->
      @filter_criterion = @item.get("filter_criteria.#{attribute}")
      @filter_criteria = @item.get("filter_criteria.#{attribute}s")
      @attribute_under_test = @item.get(attribute)
      @inclusion_criterion = @inclusion_criteria()[attribute]
      if _.isFunction @inclusion_criterion
        @inclusion_criterion()
      else if _.isString(@inclusion_criterion)
        @[@inclusion_criterion]()
    asText : ->
      return false if _.isNull(@filter_criterion) || _.isEmpty(@filter_criterion) || _.isUndefined(@filter_criterion)
      re = new RegExp(@filter_criterion.trim(),'i')
      re.test @attribute_under_test
    matchAny : ->
      return false if @filter_criteria.length == 0
      _(@filter_criteria).any (item)=> item == @attribute_under_test

  Doc = Ractive.extend
    template: '#document_group_template'
    oninit : ->
      @set('archive_upload_files',[])
      @set 'validation_criteria',
        title : =>
          other_titles = _(@parent.docs_without(@)).map (doc)->doc.get('title')
          _(other_titles).all (title)=> title != @get('title')
      @validator = new Validator(@)
      return
    onconfig : ->
      @inclusionMatcher = new InclusionMatcher(@)
    computed :
      url : -> Routes.internal_document_path(current_locale,@get('id'))
      file : -> true
      archive_file : -> false
      stripped_title : -> @get('title').replace(/\s/g,"").toLowerCase()
      title_edit_permitted : -> true
      delete_confirmation_message : ->
        "#{delete_confirmation_message} \"#{@get('title')}\"?"
      include : -> @inclusionMatcher.include()
      inclusion_criteria : ->
        title : "asText"
        filetype : "matchAny"
        noFilterActive : =>
          active_title_filter = !_.isNull(@get('filter_criteria.title')) && !_.isEmpty(@get('filter_criteria.title'))
          active_filetypes_filter = @get('filter_criteria.filetypes').length > 0
          !active_title_filter && !active_filetypes_filter
        archivedocs : =>
          _(@findAllComponents('archivedoc')).any (doc)-> doc.get('include')
    components :
      archivedoc : ArchiveDoc
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("title_error", false)
      @set("revision_error", false)
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
      internal_document_uploader.unshift('upload_documents', attached_document)
    delete_callback : (data,textStatus,jqxhr)->
      if _.isUndefined(data) # last doc in the group, so nothing returned
        @parent.remove(@)
      else
        @parent.replace(data)
    validate : ->
      @validator.validate()
  , ConfirmDeleteModal

  FiletypeSelector = Ractive.extend
    template : "#filetype_selector_template"
    oninit : ->
      @unselect()
    toggle : ->
      @event.original.preventDefault()
      @event.original.stopPropagation()
      if @get("selected")
        @unselect()
      else
        @select()
    select : ->
      @push('filter_criteria.filetypes', @get('name'))
      @set("selected",true)
    unselect : ->
      i = _(@get('filter_criteria.filetypes')).indexOf(@get('name'))
      @splice('filter_criteria.filetypes',i,1)
      @set("selected",false)

  FilterControls = Ractive.extend
    template : '#filter_controls_template'
    components :
      filetypeSelector: FiletypeSelector
    clear_filter : ->
      @set('filter_criteria', {title : "", filetypes : _(window.filetypes).map (ft)->ft.name})
      _(@findAllComponents('filetypeSelector')).each (selector)=> selector.unselect()

  Docs = Ractive.extend
    template: '#document_groups_template'
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
      filetypes : window.filetypes
      required_files_titles : window.required_files_titles
      files : files
      upload_documents : []
      _ : _ # use underscore for sorting
      context : window.context
      type : window.type
      filter_criteria : {title : "", filetypes : _(window.filetypes).map (ft)->ft.name}
    components :
      docs : Docs
      uploadDocuments : UploadDocuments
      filterControls : FilterControls
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
        file_id : ''
        url : ''
        original_filename : file.name
        filesize : file.size
        original_type : file.type
        type : "InternalDocument"
        document_group_id : null
        revision : null
      @unshift('upload_documents', attached_document)
    start_upload : ->
      flash.notify() if @get('empty_upload_files_list')
      _(@findAllComponents('uploadDocument')).each (upload_document)->
        upload_document.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()
    replace : (primary_file)-> # an archive file was added... replace the document group with the returned primary plus archive files
      @findComponent('docs').replace(primary_file)
    cancel_all : ->
      @flash_hide()
      @set('upload_documents',[])

  window.start_page = ->
    window.internal_document_uploader = new Ractive uploader_options

  start_page()

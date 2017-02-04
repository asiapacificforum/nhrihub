@AttachedDocument = Ractive.extend
  template : "#attached_document_template"
  oninit : ->
    @set 'validation_criteria',
      filesize :
        ['lessThan', @get('maximum_filesize')]
      original_type:
        ['match', @get('permitted_filetypes')]
    @set('unconfigured_validation_parameter_error',false)
    @validator = new Validator(@)
    @validator.validate() unless @get('persisted')
  computed :
    persistent_attributes : ->
      ['title', 'filename', 'filesize', 'lastModifiedDate', 'file', 'original_type'] unless @get('persisted')
    unconfigured_filetypes_error : ->
      @get('unconfigured_validation_parameter_error')
    persisted : ->
      !_.isNull(@get('id'))
    url : ->
      Routes[@get('parent_type')+"_document_path"](current_locale,@get('id'))
    truncated_title : ->
      "\""+@get('title').split(' ').slice(0,4).join(' ') + "...\""
    truncated_filename : ->
      if @get('filename').length > 50
        [base,extension] = @get('filename').split('.')
        base.slice(0,40)+"..."+extension
      else
        @get('filename')
    delete_confirmation_message : ->
      i18n.delete_document_confirmation_message + @get('truncated_title') + "?"
  remove_file : ->
    @parent.remove(@_guid)
  delete_callback : (data,textStatus,jqxhr)->
    @parent.remove(@_guid)
  download_attachment : ->
    window.location = @get('url')
  , @ConfirmDeleteModal 
@AttachedDocuments = Ractive.extend
  template : "#attached_documents_template"
  components :
    attachedDocument : AttachedDocument
  remove : (guid)->
    guids = _(@findAllComponents('attachedDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('attached_documents',index,1)

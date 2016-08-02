@AttachedDocument = Ractive.extend
  template : "#attached_document_template"
  oninit : ->
    @set 'validation_criteria',
      filesize :
        ['lessThan', @get('maximum_filesize')]
      original_type:
        ['match', @get('permitted_filetypes')]
    @set('unconfigured_validation_parameter_error',false)
    #@validator = new Validator(@)
    #@validator.validate() unless @get('persisted')
  computed :
    persistent_attributes : ->
      ['title', 'filename', 'filesize', 'lastModifiedDate', 'file', 'original_type'] unless @get('persisted')
    unconfigured_filetypes_error : ->
      @get('unconfigured_validation_parameter_error')
    persisted : ->
      !_.isNull(@get('id'))
    url : ->
      Routes[@get('parent_type')+"_document_path"](current_locale,@get('id'))
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

@AttachedDocuments = Ractive.extend
  template : "#attached_documents_template"
  components :
    attachedDocument : AttachedDocument
  remove : (guid)->
    guids = _(@findAllComponents('attachedDocument')).pluck('_guid')
    index = _(guids).indexOf(guid)
    @splice('attached_documents',index,1)

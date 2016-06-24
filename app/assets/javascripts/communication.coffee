CommunicationEdit = (node,id)->
  ractive = @
  @edit = new InpageEdit
    on : node
    object : @
    focus_element : 'input.title'
    success : (response, textStatus, jqXhr)->
      @.options.object.set(response)
      @load()
    error : ->
      console.log "Changes were not saved, for some reason"
  return {
    teardown : (id)->
    update : (id)->
    }

Ractive.decorators.communication_edit = CommunicationEdit

class Validator
  constructor : (validatee)->
    @validatee = validatee
    @validation_criteria = validatee.get('validation_criteria')
    attributes = _(@validation_criteria).keys()
    undefined_attributes = _(attributes).map (attr)=> _.isUndefined(@validatee.get(attr))
    if _(undefined_attributes).any((attr)->attr)
      throw new Error "cannot validate undefined attribute"
  validate : ->
    attributes = _(@validation_criteria).keys()
    valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
    !_(valid_attributes).any (valid)->!valid
  validate_attribute : (attribute)->
    params = @validation_criteria[attribute]
    [criterion,param] = if _.isArray(params) then params else [params]
    @[criterion].call(@,attribute,param)
  notBlank : (attribute)->
    @validatee.set(attribute, @validatee.get(attribute).trim()) unless _.isNull(@validatee.get(attribute))
    @validatee.set(attribute+"_error", _.isEmpty(@validatee.get(attribute)))
    !@validatee.get(attribute+"_error")
  lessThan : (attribute,param)->
    @validatee.set(attribute+"_error", @validatee.get(attribute) > param)
    !@validatee.get(attribute+"_error")
  numeric : (attribute)->
    @validatee.set(attribute+"_error", _.isNaN(parseInt(@validatee.get(attribute))))
    !@validatee.get(attribute+"_error")
  match : (attribute,param)->
    value = @validatee.get(attribute)
    if _.isArray(param)
      if @nonEmpty("unconfigured_validation_parameter",param)
        match = _(param).any (val)->
          re = new RegExp(val)
          re.test value
      else
        # don't trigger match error if params are empty
        match = true
    else
      re = new RegExp(param)
      match = re.test value
    @validatee.set(attribute+"_error", !match)
    !@validatee.get(attribute+"_error")
  nonEmpty : (attribute,param)->
    @validatee.set(attribute+"_error", _.isEmpty(param))
    !@validatee.get(attribute+"_error")
  remove_attribute_error : (attribute)->
    @validatee.set(attribute+"_error",false)

Communication = Ractive.extend
  template : '#communication_template'
  oninit : ->
    @validator = new Validator(@)
  computed :
    persisted : ->
      !isNaN(parseInt(@get('id')))
    formatted_date :
      get: ->
        $.datepicker.formatDate("yy, M d", new Date(@get('date')) )
      set: (val)->
        @set('date', $.datepicker.parseDate( "yy, M d", val))
    persistent_attributes : ->
      ['user_id', 'complaint_id', 'direction', 'mode', 'date', 'note']
  data :
    serialization_key : 'communication'
    validation_criteria :
      user_id : 'numeric'
      mode: ['match',['email','phone']]
  save_communication : ->
    url = Routes.complaint_communications_path(current_locale, @get('complaint_id'))
    data = @asFormData(@get('persistent_attributes'))
    if @validate()
      $.ajax
        # thanks to http://stackoverflow.com/a/22987941/451893
        #xhr: @progress_bar_create.bind(@)
        method : 'post'
        data : data
        url : url
        success : @create_communication
        context : @
        processData : false
        contentType : false # jQuery correctly sets the contentType and boundary values
  validate : ->
    @validator.validate()
  cancel_communication : ->
    @parent.pop('communications')
  delete_communication : (event)->
    ev = $.Event(event)
    ev.stopPropagation()
    data = [{name:'_method', value: 'delete'}]
    $.ajax
      url : @get('url')
      data : data
      method : 'post'
      dataType : 'json'
      context : @
      success : @update_communication
  update_communication : (response, statusText, jqxhr)->
    @parent.set('communications',response)
    @get('parent').set('communications',response)
  create_communication : (response, statusText, jqxhr)->
    @parent.set('communications',response)
    @get('parent').set('communications',response)
  remove_errors : (field)->
    if _.isUndefined(field) # after edit, failed save, and cancel, remove all errors
      error_attrs = _(_(@get()).keys()).select (k)-> k.match(/error/)
      _(error_attrs).each (a)=> @set(a,false)
    else # user types into input or changes select
      @set(field+"_error",false)

@communications = new Ractive
  el : '#communication'
  template : '#communications_template'
  data : ->
    all_staff : all_staff
  new_communication : ->
    unless @_new_communication_is_active()
      @push('communications',{id:null, complaint_id:@get('parent').get('id'), mode : null, direction : null, date:new Date()})
  _new_communication_is_active : ->
    communications = @findAllComponents('communication')
    (communications.length > 0) && _.isNull( communications[communications.length - 1].get('id'))
  onModalClose : ->
    if @_new_communication_is_active()
      @pop('communications')

Ractive.components.communication = Communication

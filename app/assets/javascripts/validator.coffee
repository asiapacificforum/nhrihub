@Validator =
  validate : ->
    attributes = _(@get('validation_criteria')).keys()
    valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
    !_(valid_attributes).any (attr)->!attr
  validate_attribute : (attribute)->
    params = @get("validation_criteria")[attribute]
    [criterion,param] = if _.isArray(params) then params else [params]
    @[criterion].call(@,attribute,param)
  notBlank : (attribute)->
    @set(attribute, @get(attribute).trim())
    @set(attribute+"_error", _.isEmpty(@get(attribute)))
    !@get(attribute+"_error")
  lessThan : (attribute,param)->
    @set(attribute+"_error", @get(attribute) > param)
    !@get(attribute+"_error")
  match : (attribute,param)->
    value = @get(attribute)
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
    @set(attribute+"_error", !match)
    !@get(attribute+"_error")
  nonEmpty : (attribute,param)->
    @set(attribute+"_error", _.isEmpty(param))
    !@get(attribute+"_error")
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)

import _ from 'underscore'

class Validator
  constructor : (validatee)->
    if typeof validatee != 'object'
      throw new Error "No ractive object has been provided to ractive validator"
    @validatee = validatee
    attributes = _(validatee.get('validation_criteria')).keys()
    error_attributes = _(attributes).map (attribute)-> attribute+"_error"
    _(error_attributes).each (attribute)->
      validatee.set(attribute,false)
    @validatee.validate = @validate.bind(@)
  validation_criteria : ->
    @validatee.get('validation_criteria')
  has_errors : ->
    attributes = _(@validatee.get('validation_criteria')).keys()
    error_attributes = _(attributes).map (attribute)-> attribute+"_error"
    _(error_attributes).any (attr)=>@validatee.get(attr)
  validate : ->
    attributes = _(@validatee.get('validation_criteria')).keys()
    _(attributes).map (attribute)=> @validate_attribute(attribute)
    !@has_errors()
  validate_attribute : (attribute)->
    params = @validation_criteria()[attribute]
    #if attribute == "duplicate_upload_pending_title"
      #debugger
    if _.isFunction(params) # not a simple validation, so the validation function is passed-in
      @validatee.set(attribute+"_error", !params())
      !@validatee.get(attribute+"_error")
    else
      # params could be:
      #   'notBlank'
      #   ['lessThan', 44]
      #   ['notBlank, {if : true}]
      #   ['lessThan', 44, {if : true}]
      #   ['match', ['one','two']]
      #   ['unique', ['a value', 'another']]
      #   -> passed in function
      [criterion, param, condition] = if _.isArray(params) then params else [params]
      if _.isUndefined(condition) && _.isObject(param) && !_.isArray(param)
        condition = param
        param = undefined
      if _.isObject(condition) && (_(condition).keys()[0]== 'if') && !_(condition).values()[0]() # condition not met
        true
      else if _.isObject(condition) && (_(condition).keys()[0]== 'if') && _(condition).values()[0]() #condition is met
        @[criterion].call(@,attribute,param)
      else # no condition
        @[criterion].call(@,attribute,param)
  notBlank : (attribute)->
    @validatee.set(attribute, @validatee.get(attribute).trim()) unless _.isEmpty(@validatee.get(attribute))
    @validatee.set(attribute+"_error", _.isEmpty(@validatee.get(attribute)))
    !@validatee.get(attribute+"_error")
  lessThan : (attribute,param)->
    @validatee.set(attribute+"_error", @validatee.get(attribute) > param)
    !@validatee.get(attribute+"_error")
  numeric : (attribute)->
    @validatee.set(attribute+"_error", _.isNaN(parseInt(@validatee.get(attribute))))
    !@validatee.get(attribute+"_error")
  nonZero : (attribute)->
    @validatee.set(attribute+"_error", parseInt(@validatee.get(attribute)) == 0)
    #console.log "validate nonZero #{attribute} value #{parseInt(@validatee.get(attribute))} result #{@validatee.get(attribute+'_error')}"
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
  unique : (attribute, params)->
    exists = _(params).any (param)=>param == @validatee.get(attribute)
    @validatee.set(attribute+"_error",exists)
    !@validatee.get(attribute+"_error")
  remove_attribute_error : (attribute)->
    @validatee.set(attribute+"_error",false)

export default Validator

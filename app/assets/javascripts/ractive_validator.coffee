# for example:
#  oninit : ->
#    @set
#      validation_criteria :
#        name : 'notBlank'
#        age : ['lessThan', 21]
#        user_id : 'numeric'
#        email : ['notBlank', {if : =>@get('has_email')}]
#        recipient : ['match', ['Fred', 'Wilma']}
#        credit_card : =>
#          @get('ccn').length == 10
# here email validation is notBlank, which has no parameters
#      age validation is lessThan, with a threshold parameter
#      user_id validation has no parameters, tests numeric
#      email validation is conditional depending on the value returned in the 'if' function
#      recipient validation is match against the array of acceptable values. If array is blank an 'unconfigured_validation_parameter' error is set to true
#      credit_card validation uses passed-in function

class @Validator
  constructor : (validatee)->
    if typeof validatee != 'object'
      throw new Error "No ractive object has been provided to ractive validator"
    @validatee = validatee
    attributes = _(validatee.get('validation_criteria')).keys()
    error_attributes = _(attributes).map (attribute)-> attribute+"_error"
    _(error_attributes).each (attribute)->
      validatee.set(attribute,false)
  validation_criteria : ->
    @validatee.get('validation_criteria')
  validate : ->
    attributes = _(@validation_criteria()).keys()
    valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
    !_(valid_attributes).any (valid)->!valid
  validate_attribute : (attribute)->
    params = @validation_criteria()[attribute]
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
    #console.log "validate numeric #{attribute} value #{parseInt(@validatee.get(attribute))} result #{@validatee.get(attribute+'_error')}"
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
  remove_attribute_error : (attribute)->
    @validatee.set(attribute+"_error",false)

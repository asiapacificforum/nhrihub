# a FormData object is passed-in for recursive conversions
# where the FormData object of the parent should be used
# e.g. in accepts_nested_attributes_for scenarios
# attributes is an array of attribute names to be included in the FormData object
# ractive instance must have an attribute 'serialization_key' to
# populate the hash key for the FormData object
# normally this is called like:
#     @asFormData(@get('persistent_attributes')
# where the persistent_attributes may contain an attribute of the form "associated_model_attributes"
# at which point this method is called recursively... passing in the formData object

local_methods =
  asFormData : (attributes,formData)->
    unless typeof(formData)=='object'
      formData = new FormData()

    if _.isUndefined(@get('serialization_key'))
      throw new ReferenceError("missing serialization_key attribute")

    array_attributes = _(attributes).select (attr)=> _.isArray(@get(attr))
    # nested attributes are named according to the Rails accepts_nested_attributes_for convention
    # if Project accept_nested_attributes_for :project_documents
    # then the ractive Project instance has attribute project_documents_attributes defined
    # and the component must be projectDocument defined by the constant ProjectDocument
    # convention over configuration!
    nested_attributes = _(attributes).select (attr)-> attr.match(/_attributes$/)
    simple_attributes = _.difference( attributes, array_attributes, nested_attributes)

    _(nested_attributes).each (attribute)=>
      # e.g. attribute = project_documents_attributes
      # or   attribute = communicants_attributes
      ar = attribute.split('_')
      ar.pop()
      ar = _(ar).map (val,i)->
             if i == ar.length-1
               val.singularize().capitalize()
             else
               debugger
               val.capitalize()
      # e.g. component = projectDocument
      # or component = communicant
      component = ar.join('').downcase()

      _(@findAllComponents(component)).each (component_instance)=>
        component_instance.asFormData(component_instance.get('persistent_attributes'),formData)

    _(array_attributes).each (attribute)=>
     value = @get(attribute)
     prefix = @get('serialization_key')
     if _.isEmpty(value)
       value = [""]

     _(value).each (item)->
       name = prefix + "["+ attribute + "][]"
       formData.append(name, item)
       return

    _(simple_attributes).each (attribute)=>
      value = @get(attribute)
      prefix = @get('serialization_key')
      name = prefix + "["+ attribute + "]"
      formData.append(name, value)
      return

    formData

  serialize : (attributes)->
    result = {}
    _(attributes).each (attribute)=>
      value = @get(attribute)
      if _.isArray(value) && _.isEmpty(value)
        result[attribute] = [""]
      else
        result[attribute] = value
    result

  remove_from_array : (array,item)->
    if @get(array).length == 0
      []
    else
      i = _(@get(array)).indexOf(item)
      @splice(array,i,1)

  local : (gmt_date)->
    $.datepicker.formatDate("M d, yy", new Date(gmt_date))

_(Ractive.prototype).extend(local_methods)

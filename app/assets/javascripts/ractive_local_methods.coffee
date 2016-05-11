# a FormData object is passed-in for recursive conversions
# where the FormData object of the parent should be used
# e.g. in accepts_nested_attributes_for scenarios
# attributes is an array of attribute names to be included in the FormData object
Ractive.prototype.asFormData = (attributes,formData)->
  unless typeof(formData)=='object'
    formData = new FormData()

  array_attributes = _(attributes).select (attr)=> _.isArray(@get(attr))
  # nested attributes are named accordint to the rails accepts_nested_attributes_for convention
  # if Project accept_nested_attributes_for :project_documents
  # then the ractive Project instance has attribute project_document_attributes defined
  # and the component must be projectDocument defined by the constant ProjectDocument
  # convention over configuration!
  nested_attributes = _(attributes).select (attr)-> attr.match(/_attributes$/)
  simple_attributes = _.difference( attributes, array_attributes, nested_attributes)

  _(nested_attributes).each (attribute)=>
    # attribute = project_documents_attributes
    ar = attribute.split('_')
    ar.pop()
    ar = _(ar).map (val,i)->
           if i!=0
             val.singularize().capitalize()
           else
             val
    # component = projectDocument
    component = ar.join('')

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

Ractive.prototype.serialize = (attributes)->
  result = {}
  _(attributes).each (attribute)=>
    value = @get(attribute)
    if _.isArray(value) && _.isEmpty(value)
      result[attribute] = [""]
    else
      result[attribute] = value
  result

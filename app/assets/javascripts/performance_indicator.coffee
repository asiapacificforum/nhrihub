@SelectedPerformanceIndicator = Ractive.extend
  template : '#selected_performance_indicator_template'
  oninit : ->
    @set
      serialization_key : "#{@parent.get('serialization_key')}[performance_indicator_associations_attributes][]"
  computed :
    performance_indicator_id : ->
      @get('performance_indicator.id')
    persistent_attributes : ->
      [ 'association_id', 'performance_indicator_id'] unless @get('persisted')
    persisted : ->
      !_.isNull(@get('id'))
  remove_indicator : (association_id,id)->
    if _.isUndefined(association_id) # not yet persisted
      @parent.remove_indicator(id)
    else
      url = @get('performance_indicator_url').replace('id',id)
      data = {"_method" : 'delete'}
      $.ajax
        method : 'post'
        data : data
        url : url
        success : @delete_performance_indicator_callback
        context : @
  delete_performance_indicator_callback : ->
    @parent.remove_indicator(@get('id'))

@PerformanceIndicatorSelect = Ractive.extend
  template : '#performance_indicator_select'
  components :
    selectedPerformanceIndicator : SelectedPerformanceIndicator
  select : ->
    performance_indicator_id = $(@event.original.target).data('id')
    @parent.add_unique_performance_indicator_id(performance_indicator_id)
    false
  remove_indicator : (id)->
    @parent.remove_performance_indicator(id)
  delete_indicator_callback : (data,status,jqxhr)->
    @parent.remove_performance_indicator(data.id)

Ractive.components.performanceindicatorselect = @PerformanceIndicatorSelect

@PerformanceIndicatorAssociation =
  remove_performance_indicator : (id)-> # it's the id of the join table, e.g. project_performance_indicator.id
    index = @performance_indicator_index(id)
    @get('performance_indicator_associations').splice(index,1)
    @validate_attribute('performance_indicator_associations')
  performance_indicator_index : (id)->
    @performance_indicator_ids().indexOf(id)
  performance_indicator_ids : ->
    _(@get('performance_indicator_associations')).map (pia)-> pia.id

  has_performance_indicator_id : (performance_indicator_id)-> # it's the id of the performance indicator, i.e. performance_indicator.id
    ids = _(@get('performance_indicator_associations')).map (pia)-> pia.performance_indicator.id
    ids.indexOf(performance_indicator_id) != -1
  add_unique_performance_indicator_id : (performance_indicator_id)->
    unless @has_performance_indicator_id(performance_indicator_id)
      performance_indicator_association =
        id : null
        association_id : @get('id')
        performance_indicator_id : performance_indicator_id
        performance_indicator :
          id : performance_indicator_id
          indexed_description : @get('all_performance_indicators')[performance_indicator_id]
      @push('performance_indicator_associations', performance_indicator_association)
      @remove_attribute_error('performance_indicator_associations')
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)


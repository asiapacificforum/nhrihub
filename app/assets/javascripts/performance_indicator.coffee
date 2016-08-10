SelectedPerformanceIndicator = Ractive.extend
  template : '#selected_performance_indicator_template'
  oninit : ->
    @set
      persistent_attributes : [ 'association_id', 'performance_indicator_id']
      serialization_key : "#{@parent.get('serialization_key')}[performance_indicator_associations_attributes][]"
  remove_indicator : (association_id,id)->
    if _.isUndefined(association_id) # not yet persisted
      @parent.remove_indicator(id)
    else
      url = @get('performance_indicator_url').
              replace('association_id',association_id).
              replace('performance_indicator_id',id)
      data = {"_method" : 'delete'}
      $.ajax
        method : 'post'
        data : data
        url : url
        success : @delete_performance_indicator_callback
        context : @
  delete_performance_indicator_callback : ->
    @parent.remove_indicator(@get('id'))

PerformanceIndicatorSelect = Ractive.extend
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
    @parent.remove_performance_indicator(data.performance_indicator_id)

Ractive.components.performanceindicatorselect = PerformanceIndicatorSelect

@PerformanceIndicatorAssociation =
  remove_performance_indicator : (id)->
    index = @performance_indicator_index(id)
    @get('performance_indicator_associations').splice(index,1)
  performance_indicator_index : (performance_indicator_id)->
    @performance_indicator_ids().indexOf(performance_indicator_id)
  performance_indicator_ids : ->
    _(@get('performance_indicator_associations')).map (pia)-> pia.performance_indicator.id
  has_performance_indicator_id : (performance_indicator_id)->
    @performance_indicator_index(performance_indicator_id) != -1
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


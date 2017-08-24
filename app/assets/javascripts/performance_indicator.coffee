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
  remove_indicator : (association_id,id)-> # association_id is the Project or MediaAppearance id, id is the ProjectPerformanceIndicator or MediaAppearancePerformanceIndicator id
    if _.isNull(id) # not yet persisted
      @parent.remove_indicator(@get('indexed_description'))
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
    @parent.remove_indicator(@get('indexed_description'))

@PerformanceIndicators = Ractive.extend
  template : '#performance_indicators_template'
  components :
    selectedPerformanceIndicator : SelectedPerformanceIndicator
  select : (id)->
    @parent.add_unique_performance_indicator_id(id)
    false
  remove_indicator : (indexed_description)->
    @parent.remove_performance_indicator(indexed_description)
  #delete_indicator_callback : (data,status,jqxhr)->
    #@parent.remove_performance_indicator(data.id)

Ractive.components.performanceIndicators = @PerformanceIndicators

# mixin for ractive views
@PerformanceIndicatorAssociation =
  remove_performance_indicator : (indexed_description)->
    index = @performance_indicator_index(indexed_description)
    @get('performance_indicator_associations').splice(index,1)
    @validate_attribute('performance_indicator_associations') if @get('performance_indicator_required')
  performance_indicator_index : (indexed_description)->
    @performance_indicator_ids().indexOf(indexed_description)
  performance_indicator_ids : ->
    _(@get('performance_indicator_associations')).map (pia)-> pia.performance_indicator.indexed_description
  has_performance_indicator_id : (performance_indicator_id)-> # it's the id of the performance indicator, i.e. performance_indicator.id
    ids = _(@get('performance_indicator_associations')).map (pia)-> pia.performance_indicator.id
    ids.indexOf(performance_indicator_id) != -1
  add_unique_performance_indicator_id : (performance_indicator_id)->
    unless @has_performance_indicator_id(performance_indicator_id)
      performance_indicator_association =
        id : null
        association_id : @get('id') # no id for a new collectionItem
        performance_indicator_id : performance_indicator_id # need this
        performance_indicator :
          id : performance_indicator_id
          indexed_description : @get('performance_indicators')[performance_indicator_id]
      @push('performance_indicator_associations', performance_indicator_association)
      @remove_attribute_error('performance_indicator_associations')
  remove_attribute_error : (attribute)->
    @set(attribute+"_error",false)


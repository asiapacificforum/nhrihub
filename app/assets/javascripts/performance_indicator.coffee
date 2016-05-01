PerformanceIndicatorSelect = Ractive.extend
  template : '#performance_indicator_select'
  select : ->
    id = $(@event.original.target).data('id')
    @parent.add_unique_performance_indicator_id(id)
    false
  remove_indicator : (performance_indicator_id,project_id)->
    if _.isNull(project_id)
      @parent.remove_performance_indicator(performance_indicator_id)
    else
      url = Routes.project_project_performance_indicator_path(current_locale, project_id, performance_indicator_id)
      data = { _method : 'delete' }
      $.ajax
        url : url
        data : data
        method : 'post'
        success : @delete_indicator_callback
        context : @
  delete_indicator_callback : (data,status,jqxhr)->
    @parent.remove_performance_indicator(data.performance_indicator_id)


Ractive.components.performanceindicatorselect = PerformanceIndicatorSelect

window.PerformanceIndicatorAssociation =
  remove_performance_indicator : (id)->
    index = @performance_indicator_index(id)
    @get('performance_indicator_ids').splice(index,1)
  performance_indicator_index : (id)->
    @get('performance_indicator_ids').indexOf(id)
  has_performance_indicator_id : (id)->
    @performance_indicator_index(id) != -1
  add_unique_performance_indicator_id : (id)->
    unless @has_performance_indicator_id(id)
      @push('performance_indicator_ids', id)

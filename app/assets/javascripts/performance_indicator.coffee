$ ->
  PerformanceIndicatorSelect = Ractive.extend
    template : '#performance_indicator_select'
    select : ->
      id = $(@event.original.target).data('id')
      @parent.push('performance_indicator_ids', id)
      false
    remove_indicator : (project_indicator_id,project_id)->
      url = Routes.project_project_performance_indicator_path(current_locale, project_id, project_indicator_id)
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

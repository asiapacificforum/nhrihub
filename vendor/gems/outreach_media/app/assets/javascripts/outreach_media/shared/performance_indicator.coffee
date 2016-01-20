$ ->
  PerformanceIndicatorSelect = Ractive.extend
    template : '#performance_indicator_select'
    select : ->
      id = $(@event.original.target).data('id')
      outreach_event = @parent
      @parent.push('performance_indicator_ids', id)
      false

  Ractive.components.performanceindicatorselect = PerformanceIndicatorSelect

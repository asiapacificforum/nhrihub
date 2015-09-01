$ ->
  Area = Ractive.extend
    template : '#area_template'

  Metric = Ractive.extend
    template : '#metric_template'

  Description = Ractive.extend
    template : '#description_template'
    components :
      area : Area

  MediaAppearance = Ractive.extend
    template : '#media_appearance_template'
    components :
      description : Description
      metric : Metric
    expand : ->
      $(@find('.collapse')).collapse('show')
    compact : ->
      $(@find('.collapse')).collapse('hide')

  window.media = new Ractive
    el : '#media_appearances'
    template : '#controls_template'
    data :
      expanded : false
      media_appearances: media_appearances
    components :
      ma : MediaAppearance
    expand : ->
      @set('expanded', true)
      _(@findAllComponents('ma')).each (ma)-> ma.expand()
    compact : ->
      @set('expanded', false)
      _(@findAllComponents('ma')).each (ma)-> ma.compact()

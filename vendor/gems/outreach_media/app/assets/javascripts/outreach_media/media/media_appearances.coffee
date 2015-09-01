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

  window.media = new Ractive
    el : '#media_appearances'
    template : '#media_appearances_template'
    data : {media_appearances: media_appearances }
    components :
      ma : MediaAppearance

  window.media_control = new Ractive
    el : '#media_appearances_controls'
    template : '#controls_template'
    data : { expanded : false }
    expand : ->
      @set('expanded', true)
      @collapse_elements.collapse('show')
    compact : ->
      @set('expanded', false)
      @collapse_elements.collapse('hide')
    collapse_elements :
      $('#media_appearances .media_appearance .collapse')

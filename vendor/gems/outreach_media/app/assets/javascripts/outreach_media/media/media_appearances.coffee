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
    computed :
      areas : ->
        _(@get('description').areas).map (a)-> a.name
      include : ->
        @_matches_title() && @_matches_from() && @_matches_to() && @_matches_area()
    _matches_from : ->
      new Date(@get('date')) >= new Date(@get('sort_criteria.from'))
    _matches_to : ->
      new Date(@get('date')) <= new Date(@get('sort_criteria.to'))
    _matches_area : ->
      if @get('sort_criteria.areas').length > 0
        matches = _.intersection(@get('areas'), @get('sort_criteria.areas'))
        matches.length > 0
      else
        true
    _matches_subarea : ->
    _matches_people_affected : ->
    _matches_violation_severity : ->
    _matches_violation_coefficient : ->
    _matches_positivity_rating : ->
    _matches_title : ->
      re = new RegExp(@get('sort_criteria.title'),'i')
      re.test(@get('title'))
    expand : ->
      $(@find('.collapse')).collapse('show')
    compact : ->
      $(@find('.collapse')).collapse('hide')

  window.media = new Ractive
    el : '#media_appearances'
    template : '#media_appearances_template'
    data :
      expanded : false
      media_appearances: media_appearances
      sort_criteria :
        title : ""
        from : new Date(1995,0,1)
        to : new Date()
        areas : []
    components :
      ma : MediaAppearance
    expand : ->
      @set('expanded', true)
      _(@findAllComponents('ma')).each (ma)-> ma.expand()
    compact : ->
      @set('expanded', false)
      _(@findAllComponents('ma')).each (ma)-> ma.compact()

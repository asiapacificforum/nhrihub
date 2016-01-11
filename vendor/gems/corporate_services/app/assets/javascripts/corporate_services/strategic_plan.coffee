$ ->
  Ractive.DEBUG = false

  PerformanceIndicator = Ractive.extend
    template : '#performance_indicator_template'
    computed :
      persisted : ->
        !isNaN(parseInt(@get('id')))
    remove_description_errors : ->
      @set("description_error","")
    create_save : ->
      context = $(@find('.new_performance_indicator'))
      url = @parent.get('create_performance_indicator_url')
      data = context.find(':input').serializeArray()
      data.push({name: 'performance_indicator[activity_id]', value : @get('activity_id')})
      if @validate()
        $.ajax
          type : 'post'
          url : url
          data : data
          dataType : 'json'
          success : @create_performance_indicator
          context : @
    validate : ->
      @set('description', @get('description').trim())
      if @get('description') == ""
        @set("description_error",true)
        false
      else
        true
    create_performance_indicator : (response, statusText, jqxhr)->
      UserInput.reset()
      @parent.set('performance_indicators',response)
    delete_this : (event,object)->
      ev = $.Event(event)
      ev.stopPropagation()
      data = [{name:'_method', value: 'delete'}]
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @update_performance_indicator
    update_performance_indicator : (resp, statusText, jqxhr)->
      UserInput.reset()
      @parent.set(resp)
    remove_errors : ->
      @remove_description_errors()
    show_reminders_panel : ->
      $('#reminders_modal').modal('show')
    show_notes_panel : ->
      $('#notes_modal').modal('show')
    show_rules_panel : ->
      $('#rules_modal').modal('show')
    create_stop : ->
      UserInput.reset()
      @parent.remove_performance_indicator_form()

  Activity = Ractive.extend
    template : '#activity_template'
    components :
      pi : PerformanceIndicator
    computed :
      persisted : ->
        !isNaN(parseInt(@get('id')))
    create_stop : ->
      UserInput.reset()
      @parent.remove_activity_form()
    create_save : ->
      context = $(@el)
      url = @parent.get('create_activity_url')
      data = context.find('.row.new_activity :input').serializeArray()
      data.push({name: 'activity[outcome_id]', value : @get('outcome_id')})
      if @validate()
        $.ajax
          type : 'post'
          url : url
          data : data
          dataType : 'json'
          success : @create_activity
          context : @
    validate : ->
      @set('description', @get('description').trim())
      if @get('description') == ""
        @set("description_error",true)
        false
      else
        true
    create_activity : (response, statusText, jqxhr)->
      UserInput.reset()
      @parent.set('activities',response)
      #@parent.show_add_activity()
    delete_this : (event,object)->
      ev = $.Event(event)
      ev.stopPropagation()
      data = [{name:'_method', value: 'delete'}]
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @update_activity
    update_activity : (resp, statusText, jqxhr)->
      UserInput.reset()
      @parent.set(resp)
    remove_errors : ->
      @remove_description_errors()
    remove_description_errors : ->
      @set("description_error","")
    new_performance_indicator : ->
      @push('performance_indicators',{description : '', indexed_description: '', target: '', id : null, activity_id : @get('id'), url:null, description_error:"", progress:""})
      UserInput.claim_user_input_request(@,'remove_performance_indicator_form')
    remove_performance_indicator_form : ->
      if _.isNull(@findAllComponents('pi')[@get('performance_indicators').length-1].get('id'))
        @pop('performance_indicators')

  Outcome = Ractive.extend
    template : '#outcome_template'
    computed :
      persisted : ->
        !isNaN(parseInt(@get('id')))
    components :
      activity : Activity
    create_stop : ->
      UserInput.reset()
      @parent.remove_outcome_form()
    create_save : ->
      context = $(@el)
      url = @parent.get('create_outcome_url')
      data = context.find('.row#new_outcome :input').serializeArray()
      data.push({name: 'outcome[planned_result_id]', value : @get('planned_result_id')})
      if @validate()
        $.ajax
          type : 'post'
          url : url
          data : data
          dataType : 'json'
          success : @create_outcome
          context : @
    validate : ->
      @set('description', @get('description').trim())
      if @get('description') == ""
        @set("description_error",true)
        false
      else
        true
    create_outcome : (response, statusText, jqxhr)->
      UserInput.reset()
      @parent.set('outcomes',response)
      @parent.show_add_outcome()
    remove_description_errors : ->
      @set("description_error","")
    remove_errors : ->
      @remove_description_errors()
    delete_this : (event,object)->
      ev = $.Event(event)
      ev.stopPropagation()
      data = [{name:'_method', value: 'delete'}]
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @update_pr
    update_pr : (resp, statusText, jqxhr)->
      UserInput.reset()
      @parent.set(resp)
    new_activity : ->
      @push('activities',{description : '', indexed_description: '', id : null, outcome_id : @get('id'), url:null, description_error:"" })
      UserInput.claim_user_input_request(@,'remove_activity_form')
    remove_activity_form : ->
      if _.isNull(@findAllComponents('activity')[@get('activities').length-1].get('id'))
        @pop('activities')

  PlannedResult = Ractive.extend
    template : '#planned_result_template'
    computed :
      persisted : ->
        !isNaN(parseInt(@get('id')))
    components :
      outcome : Outcome
    oninit : ->
      if !@get('persisted')
        @parent.hide_add_planned_result()
    create_stop : ->
      UserInput.reset()
      @parent.remove_planned_result_form()
    create_save : ->
      context = $(@el)
      url = @parent.get('create_planned_result_url')
      data = context.find('.new_planned_result :input').serializeArray()
      data.push({name: 'planned_result[strategic_priority_id]', value : @get('strategic_priority_id')})
      if @.validate(data)
        $.ajax
          type : 'post'
          url : url
          data : data
          dataType : 'json'
          success : @create_pr
          context : @
    validate : ->
      @set('description', @get('description').trim())
      if @get('description') == ""
        @set("description_error",true)
        false
      else
        true
    remove_description_errors : ->
      @set("description_error",false)
    remove_errors : ->
      @remove_description_errors()
    create_pr : (response, statusText, jqxhr)->
      UserInput.reset()
      @parent.set('planned_results',response)
      @parent.show_add_planned_result()
    delete_this : (event)->
      ev = $.Event(event)
      ev.stopPropagation()
      data = [{name:'id', value:@get('id')}, {name:'_method', value: 'delete'}]
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @update_all_pr
    update_pr : (response, statusText, jqxhr)->
      @set(response)
    update_all_pr : (response, statusText, jqxhr)->
      UserInput.reset()
      @parent.set('planned_results',response)
    new_outcome : ->
      UserInput.claim_user_input_request(@,'remove_outcome_form')
      @push('outcomes',{description : '', indexed_description: '', id : null, planned_result_id : @get('id'), url:null, description_error:""})
      @hide_add_outcome()
    remove_outcome_form : ->
      if _.isNull(@findAllComponents('outcome')[@get('outcomes').length-1].get('id'))
        @pop('outcomes')
      @show_add_outcome()
    _add_outcome : ->
      $(@parent.el).
        find('.new_outcome').
        closest('.row')
    hide_add_outcome : ->
      @_add_outcome().hide()
    show_add_outcome : ->
      @_add_outcome().show()

  # response to save is assumed to be an array of all
  # the strategic priorities on the page
  EditInPlace = (node,id)->
    ractive = @
    @edit = new InpageEdit
      on : node
      object : @
      focus_element : 'input.title'
      success : (response, textStatus, jqXhr)->
        ractive = @.options.object
        # the whole dataset is replaced... Ractive figures out
        # what has changed and what to re-render
        strategic_plan.set('strategic_priorities',response)
        @load()
      error : ->
        console.log "Changes were not saved, for some reason"
    return {
      teardown : (id)->
        # ractive.edit.off()
      update : (id)->
        if _.isUndefined(id)
          # ractive.edit.off()
        else
          # item was added
          # enable EditInPlace for the node
          # @edit = new InpageEdit
          #   on : node
          #   object : @
          #   focus_element : 'input.title'
          #   success : (response, textStatus, jqXhr)->
          #     ractive = @.options.object
          #     # the whole dataset is replaced... Ractive figures out
          #     # what has changed and what to re-render
          #     strategic_plan.set('strategic_priorities',response)
          #     @.show()
          #   error : ->
          #     console.log "Changes were not saved, for some reason"
          }

  Ractive.decorators.inpage_edit = EditInPlace

  StrategicPriority = Ractive.extend
    onconfig : ->
      @set('original_description', @get('description'))
      @set('original_priority_level', @get('priority_level'))
    template : '#strategic_priority_template'
    components :
      pr : PlannedResult
    computed :
      length : ->
        if @get('description')
          @get('description').length
        else
          0
      count : ->
        Math.max(0,(100 - @get('length')))
      spid : ->
        window.strategic_plan.get('id')
      persisted : ->
        !isNaN(parseInt(@get('id')))
    new_planned_result: ->
      UserInput.claim_user_input_request(@,'remove_planned_result_form')
      @push('planned_results', {id : null, description : "", strategic_priority_id : @get('id'), description_error:"", outcomes:[]})
    cancel : ->
      UserInput.reset()
      @parent.get('strategic_priorities').shift() # it's only the first one that ever gets cancelled
    form : ->
      $(@nodes.new_strategic_priority)
    save : ->
      data = @form().serializeArray()
      url = @form().attr('action')
      if @validate(data)
        $.post(url, data, @update_sp, 'json')
    update_sp : (data,textStatus,jqxhr)->
      UserInput.reset()
      strategic_plan.set('strategic_priorities', data)
    delete : ->
      data = {'_method' : 'delete'}
      # TODO if confirm
      $.post(@get('url'), data, @update_sp, 'json')
    validate : ->
      pl = @._validate('priority_level')
      desc = @._validate('description')
      pl && desc
    _validate : (field)->
      if _.isString(@get(field))
        @set(field, @get(field).trim())
      value = @get(field)
      if value == "" || _.isNull(value)
        @set(field+"_error",true)
        false
      else
        true
    remove_priority_level_errors : ->
      @set("priority_level_error",false)
    remove_description_errors : ->
      @set("description_error",false)
    remove_errors : ->
      @remove_priority_level_errors() && @remove_description_errors()
    _add_planned_result : ->
      $(@parent.el).
        find('.new_planned_result').
        closest('.row')
    hide_add_planned_result : ->
      @_add_planned_result().
        hide()
    show_add_planned_result : ->
      @_add_planned_result().
        show()
    remove_planned_result_form : ->
      if _.isNull(@findAllComponents('pr')[@get('planned_results').length-1].get('id'))
        @pop('planned_results')
      @show_add_planned_result()

  window.strategic_plan = new Ractive
    el : "#strategic_plan"
    template: "#strategic_plan_template"
    data: strategic_plan_data
    components :
      sp : StrategicPriority
    new_strategic_priority : ->
      UserInput.claim_user_input_request(@,'remove_strategic_priorities_form')
      # add only if there are no strategic priorities
      # of if the most recent is persisted
      if @.findAllComponents().length == 0 || @.findComponent().get('persisted')
        strategic_plan.unshift('strategic_priorities', {id:null, description: '', priority_level:null} )
    remove_strategic_priorities_form : ->
      @get('strategic_priorities').shift() # it's only the first one that ever gets cancelled


window.outreach_media_datepicker =
  start : (outreach_media)->
    $('#from').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "dd/mm/yy"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          outreach_media.set_sort_criteria_from_date(selectedDate)

    $('#to').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "dd/mm/yy"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          outreach_media.set_sort_criteria_to_date(selectedDate)


filter_criteria_datepicker =
  start : (collection)->
    $('#from').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "yy, M dd"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          collection.set_filter_criteria_from_date(selectedDate)

    $('#to').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "yy, M dd"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          collection.set_filter_criteria_to_date(selectedDate)

export default filter_criteria_datepicker

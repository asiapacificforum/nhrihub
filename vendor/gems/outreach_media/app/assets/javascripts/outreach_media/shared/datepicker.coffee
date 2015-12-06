window.media_datepicker =
  start : ->
    $('#from').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      numberOfMonths: 3
      dateFormat: "dd/mm/yy"
      onClose: (selectedDate) ->
        unless selectedDate == ""
          media.set('sort_criteria.from',$.datepicker.parseDate("dd/mm/yy",selectedDate))
          $('#to').datepicker 'option', 'minDate', selectedDate
          media.update()

    $('#to').datepicker
      maxDate: new Date()
      defaultDate: '+1w'
      changeMonth: true
      changeYear: true
      dateFormat: "dd/mm/yy"
      numberOfMonths: 3
      onClose: (selectedDate) ->
        unless selectedDate == ""
          media.set('sort_criteria.to',$.datepicker.parseDate("dd/mm/yy",selectedDate))
          $('#from').datepicker 'option', 'maxDate', selectedDate
          media.update()

$ ->
  media_datepicker.start()

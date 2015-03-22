# disable the bootstrap javascript event handlers for the navigation dropdown menu
# css is used to enable menu dropdown on hover overH

$ ->
  $(document).off('click.bs.dropdown.data-api').off('keydown.bs.dropdown.data-api')

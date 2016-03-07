$ ->
  Collection.CollectionItem.prototype._validate_attachment = ->
    _.isEmpty(@get('fileupload')) || @validate_file_constraints()
  Collection.CollectionItem.prototype._matches_positivity_rating = ->
    true

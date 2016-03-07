$ ->
  Collection.CollectionItem.prototype._validate_attachment = ->
    _.isEmpty(@get('fileupload')) || @validate_file_constraints()

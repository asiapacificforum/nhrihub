Collection.CollectionItem.prototype.validate = ->
  _.isEmpty(@get('fileupload')) || @validate_file_constraints()

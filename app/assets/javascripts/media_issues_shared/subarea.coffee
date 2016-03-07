class Collection.Subarea
  constructor : (attrs)->
    @id = attrs.id
    @name = attrs.name
    @full_name = attrs.full_name
    @extended_name = attrs.extended_name

  @all : ->
    _(subareas).map (sa)->
      new Collection.Subarea(sa)

  @find : (id)->
    _(@all()).detect (a)-> a.id == id

  @find_by_extended_name : (extended_name)->
    _(@all()).detect (a)-> a.extended_name == extended_name

  @hr_violation : ->
    @find_by_extended_name("Human Rights Violation")

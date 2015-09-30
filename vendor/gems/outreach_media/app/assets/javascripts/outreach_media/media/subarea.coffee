class @Subarea
  constructor : (attrs)->
    @id = attrs.id
    @name = attrs.name
    @full_name = attrs.full_name
    @extended_name = attrs.extended_name

  @all : ->
    _(subareas).map (sa)->
      new Subarea(sa)

  @find : (id)->
    _(@all()).detect (a)-> a.id == id

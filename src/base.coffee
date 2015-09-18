global.$game.base = {} if not global.$game.base

base = global.$game.base

base.move = (what, to)->
  what.location = $game.rooms.$nowhere if not what.location
  to.contents = [] if not to.contents
  if what.location.contents
    what.location.contents = what.location.contents.remove(what)
  to.contents.push what
  what.location = to

base.moveTo = (to)->
  base.move(this, to)
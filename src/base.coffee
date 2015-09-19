global.$game.base = {} if not global.$game.base

global.$game.base.move = (what, to)->
  what.location = global.$game.$index.rooms.$nowhere if not what.location
  to.contents = [] if not to.contents
  if what.location.contents
    what.location.contents = what.location.contents.remove(what)
  to.contents.push what
  what.location = to

global.$game.base.moveTo = (to)->
  global.$game.base.move(this, to)
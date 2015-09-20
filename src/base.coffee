global.$game.common = {} if not global.$game.common

global.$game.common.move = (what, to)->
  what.location = global.$game.$index.rooms.$nowhere if not what.location
  to.contents = [] if not to.contents
  if what.location.contents
    what.location.contents = what.location.contents.remove(what)
  to.contents.push what
  what.location = to

global.$game.common.moveTo = (to)->
  global.$game.common.move(this, to)

global.$game.common.question = (socket, prompt, criteria, callback)->
  readline = require("readline")
  rl = readline.createInterface(socket, socket)
  rl.question prompt, (answer) ->
    rl.close()
    result = criteria(answer)
    if result
      socket.tell(result)
      return setTimeout ->
        global.$game.common.question socket, prompt, criteria, callback
      , 0
    callback(answer)
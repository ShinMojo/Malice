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
    return criteria(answer) if not callback
    result = criteria(answer)
    if result
      socket.tell(result)
      return setTimeout ->
        global.$game.common.question socket, prompt, criteria, callback
      , 0
    callback(answer)

global.$game.common.choice = (socket, prompt, choices, callback) ->
  what = prompt + "\n"
  choices.forEach (value, key)->
    what += "[" + (key + 1) + "] " + value + "\n"
  global.$game.common.question socket, what, (answer)->
    return "Please enter a number between 1 and #{choices.length}." if isNaN(parseInt(answer)) || parseInt(answer) < 1 || parseInt(answer) > choices.length
  , (finalAnswer) ->
    callback(choices[parseInt(finalAnswer)-1])


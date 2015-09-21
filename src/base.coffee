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
  deferred = require("q").defer()
  readline = require("readline")
  askQuestion = ->
    rl = readline.createInterface(socket, socket)
    rl.question prompt, (answer) ->
      rl.close()
      if answer == "@abort"
        return deferred.reject("Abort")
      result = if criteria then criteria(answer) else false
      if result
        socket.tell(result)
        return askQuestion()
      deferred.resolve(answer)
  askQuestion()
  return deferred.promise.nodeify(callback)

global.$game.common.yesorno = (socket, prompt, callback)->
  deferred = require("q").defer()
  global.$game.common.question socket, prompt, (criteria)->
    return "Please answer yes or no." if not criteria.toLowerCase().startsWith("y") && not criteria.toLowerCase().startsWith("n")
  , (err, answer)->
    if answer.toLowerCase().startsWith("y") then deferred.resolve("yes") else deferred.reject("no")
  return deferred.promise.nodeify(callback)

global.$game.common.choice = (socket, prompt, choices, callback) ->
  deferred = require("q").defer()
  what = prompt + "\n"
  choices.forEach (value, key)->
    what += "[" + (key + 1) + "] " + value + "\n"
  global.$game.common.question socket, what, (answer)->
    return "Please enter a number between 1 and #{choices.length} or " + "@abort".underline + " to abort." if isNaN(parseInt(answer)) || parseInt(answer) < 1 || parseInt(answer) > choices.length
  , (err, finalAnswer) ->
    return deferred.reject("Abort") if err
    deferred.resolve(choices[parseInt(finalAnswer)-1])
  return deferred.promise.nodeify(callback)

global.$game.common.gameTime = ->
  moment = require("moment")
  now = moment()
  now.year(now.year() + 85)

global.$game.$index = {} if not global.$game.$index
global.$game.$index.players = {} if not global.$game.$index.players

if not global.$game.classes.Player
  global.$game.classes.Player = class Player
    constructor:->
      @type = "$game.classes.Player"
      this.init.apply(this, arguments)

player = global.$game.classes.Player.prototype

player.init = (@name, @user, @password, @lastIp, @location = global.$game.$index.rooms.$nowhere) ->
  throw new Error("Player names must be unique.") if global.$game.$index.players[@name]
  throw new Error("Player must be associated with a user.") if not @user
  global.$game.$index.players[@name] = this
  @salt = require("node-uuid").v4()
  @user.player = this

player.moveTo = global.$game.common.moveTo

player.tell = (what)->
  @user.tell(what);

player.walkThrough = (exit) ->
  exit.accept(this)
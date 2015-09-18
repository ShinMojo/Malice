if not global.$game.classes.Player
  global.$game.Player = class Player
    constructor:->
      @type = "$game.classes.Player"
      this.init.apply(this, arguments)

player = global.$game.classes.Player.prototype

user.init = (@name, @email, @password, @lastIp, @location = global.$game.$nowhere) ->
  @salt = require("node-uuid").v4()

user.moveTo = global.$game.base.moveTo



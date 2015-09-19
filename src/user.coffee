global.$game.classes = {} if ! global.$game.classes

if not global.$game.classes.User
  global.$game.classes.User = class User
    constructor:->
      @type = "$game.classes.User"
      this.init.apply(this, arguments)

user = global.$game.classes.User.prototype

user.init = (@name, @email, @password, @lastIp) ->
  @salt = require("node-uuid").v4()

user.moveTo = global.$game.base.moveTo

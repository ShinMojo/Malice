global.$game.classes = {} if ! global.$game.classes

if not global.$game.classes.User
  global.$game.classes.User = class User
    constructor:->
      @type = "$game.classes.User"
      this.init.apply(this, arguments)

user = global.$game.classes.User.prototype

global.$game.$index.users = {} if not global.$game.$index.users

user.init = (@name, @email, password, @lastIp) ->
  throw new Error("Username already in use.") if global.$game.$index.users[@name]
  @salt = require("node-uuid").v4()
  global.$game.$index.users[@name] = this
  crypto = require "crypto"
  hash = crypto.createHash "sha256"
  hash.update password + @salt
  @password = hash.digest("hex")

user.moveTo = global.$game.common.moveTo

user.tell = (what) ->
  global.$driver.getSocket(this)?.tell(what)

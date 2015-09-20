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

user.handleConnection = (socket) ->
  if not socket.user.player
    prompt = """
Please make a slection from the following options:
1. Make a new character
2. Quit

"""
  else
    prompt = """
Please make a slection from the following options:
1. Enter the game as #{socket.user.player.name}
2. Quit (Your character will go to sleep and be vulnerable)

"""

  global.$game.common.question socket, prompt, (answer) ->
    return "Invalid selection." if answer.trim() != "1" && answer.trim() != "2"
  , (answer)->
    if(answer == "2")
      return socket.end()
    if(answer == "1")
      if(socket.user.player)
        x = 5
        socket.tell("Now entering the world in 5...")
        ready = ->
          x--
          if(x == 0)
            user.player.goIC(socket)
          else
            socket.tell(x + "...")
            setTimeout ready, 1000
        return setTimeout ready, 1000
      user.makeNewPlayer(socket)

user.connected = ->
  if global.$driver.getSocket() then return true else return false

user.makeNewPlayer = (socket)->
  socket.tell("Warning: ".red + "You must complete this process without disconnecting, otherwise you will have to start over.")
  q = global.$game.common.question
  sexPrompt = """
What is your characters sex?
(We're going to keep it simple here, although we do understand sometimes the reality can be a little more complex.)
(M)ale
(F)emale

"""
  q socket, sexPrompt, (sex)->
    return "Please, let's keep this straight forward." if not sex.toLowerCase().startsWith("m") and not sex.toLowerCase().startsWith("f")
  , (sex) ->
    heightPrompt = """
And how tall are they? Please answer in meters, between 0.5 and 3.
For example, if your character was 1.8 meters (about 6 feet tall), you would type: 1.8

"""
    q socket, heightPrompt, (height) ->
      height = parseFloat(height)
      return "Please enter a number between 0.5 and 3, like 1.8." if isNaN(height) || height < 0.5|| height > 3
    , (height) ->



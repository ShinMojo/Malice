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
  options = ["Name", "Birthday", "Sex", "Looks", "Stats", "Skills", "Abort"]
  remaining = ["Name", "Birthday", "Sex", "Looks", "Stats", "Skills"]
  results = {}
  makePlayerLoop = ->
    prompt = """
#{'Character Generation Main Menu'.bold}
Things you still must do before you finish: #{remaining.join(', ')}
"""
    if remaining.length == 0 && options.length == 6
      options.push("Finish")
    global.$game.common.choice socket, prompt, options, (option)->
      if option == "Abort" then return
      if option == "Finish" then return
      user.charGen[option] socket, (stats)->
        results[option] = stats
        remaining.remove option
        makePlayerLoop()
  makePlayerLoop()

user.charGen = {} if not user.charGen

user.charGen.formatProgress = (progress)->
  results = ""
  results += "Alias: " + progress.Name.alias + "\n" if progress.Name
  results += "First Name: " + progress.Name.firstName + "\n" if progress.Name
  results += "Last Name: " + progress.Name.lastName + "\n" if progress.Name
  results += "Middle Name: " + progress.Name.middleName + "\n" if progress?.Name?.middleName
  results += "Sex: " + progress.Sex + "\n" if progress.Sex
  results += "Birthday: " + progress.Birthday + "\n" if progress.Birthday
  results += "Height: " + progress.Looks.Height + "m" + " (" + global.$game.constants.player.formatHeight(progress.Looks.Height) + ")" + "\n" if progress.Looks
  results += "Weight: " + progressm.Looks.Weight

user.charGen.Name = (socket, callback)->
  namePrompt = """
What is your character's most common name?
This can be their first name, last name, or a nick name that they're always called. It should be a single word.

"""
  global.$game.common.question socket, namePrompt, (criteria) ->
    return "It must be a single word." if criteria.trim().indexOf(" ") > -1
    _ = require("underscore")
    existingUsers = _(global.$game.$index.users).find (user) ->
      user.name.toLowerCase() == criteria
    if existingUsers then return "That name is taken."
    existingPlayers = _(global.$game.$index.players).find (player) ->
      player.name.toLowerCase() == criteria
    if existingPlayers then return "That name is taken."
  , (alias) ->
    global.$game.common.question socket, "Ok. What is their real first name from birth?\n", (criteria)->
      return "Please enter their first name from birth." if criteria.trim().length < 2
    , (firstName)->
      global.$game.common.question socket, "Now please enter your last name, or the last name of the mother at birth?\n", (criteria)->
        return "Please enter their last name from birth." if criteria.trim().length < 2
      , (lastName)->
        global.$game.common.question socket, "And if they have a middle name, please enter it now, otherwise leave it blank.\n", (middleName)->
          callback
            alias:alias
            firstName:firstName
            lastName:lastName
            middleName:middleName

user.charGen.Sex = (socket, callback)->
  q = global.$game.common.question
  sexPrompt = """
What is your characters #{'sex'.bold}
(We're going to keep it simple here, although we do understand sometimes the reality can be a little more complex.)
[M]ale
[F]emale
"""
  q socket, sexPrompt, (sex)->
    return "Please, let's keep this straight forward." if not sex.toLowerCase().startsWith("m") and not sex.toLowerCase().startsWith("f")
  , (sex) ->
    sex = if sex.toLowerCase().startsWith("m") then "male" else "female"
    callback(sex)

user.charGen.Looks = (socket, callback) ->
  q = global.$game.common.question
  heightPrompt = """
What is the #{'height'.bold} of your character? Please answer in meters, between 0.5 and 3.
For example, if your character was 1.8 meters (about 6 feet tall), you would type: 1.8
"""
  q socket, heightPrompt, (height) ->
    return "Please enter a number between 0.5 and 3, like 1.8." if isNaN(height) || height < 0.5|| height > 3
  , (height) ->
    height = Math.floor(parseFloat(height) * 1000) / 1000
    $game.common.choice socket, "That would make you #{global.$game.constants.player.formatHeight(height)}. And your weight in kilograms?", (criteria)->
      return "Please enter a number between 15 and 300." if isNaN(parseInt(criteria)) || parseInt(criteria) < 15 || parseInt(criteria) > 300
    , (weight)->
      weight = parseInt(weight)
      $game.common.choice socket, "What would you like your #{'hair cut'.bold} to be?", global.$game.constants.player.hairCut, (hairCut)->
        $game.common.choice socket, "And the #{'hair style'.bold} to go with your #{hairCut} hair?", global.$game.constants.player.hairStyle, (hairStyle)->
          $game.common.choice socket, "And is the #{'hair color'.bold} of your #{hairCut} #{hairStyle} hair?", global.$game.constants.player.hairColor, (hairColor)->
            $game.common.choice socket, "Fine. You have #{hairCut} #{hairColor} #{hairStyle} hair.\nWhat is your #{'eye color'.bold}?", global.$game.constants.player.eyeColor, (eyeColor)->
              $game.common.choice socket, "Ok, and the #{'eye style'.bold} of these #{eyeColor} eyes?", global.$game.constants.player.eyeStyle, (eyeStyle)->
                $game.common.choice socket, "Perfect. You've got #{eyeStyle} #{eyeColor} eyes. Let's talk about your #{'skin'.bold}. How would you describe it?", global.$game.constants.player.skinStyle, (skinStyle)->
                  $game.common.choice socket, "Great. And what's the #{'skin color'.bold} of your #{skinStyle}?", global.$game.constants.player.skinColor, (skinColor)->
                    callback
                      height:height,
                      weight:weight,
                      hairCut:hairCut,
                      hairStyle:hairStyle,
                      eyeColor:eyeColor,
                      eyeStyle:eyeStyle,
                      skinColor:skinColor,
                      skinStyle:skinStyle





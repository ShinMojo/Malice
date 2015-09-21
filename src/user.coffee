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
  , (err, answer)->
    if(answer == "2")
      return socket.end()
    if(answer == "1")
      if(socket.user.player)
        x = 5
        socket.tell("Now entering the world in 5...")
        ready = ->
          x--
          if(x == 0)
            socket.user.player.goIC(socket)
          else
            socket.tell(x + "...")
            setTimeout ready, 1000
        return setTimeout ready, 1000
      socket.user.makeNewPlayer(socket)

user.connected = ->
  if global.$driver.getSocket() then return true else return false

user.makeNewPlayer = (socket)->
  socket.tell("Warning: ".red + "You must complete this process without disconnecting, otherwise you will have to start over.")
  options = ["Name", "Birthday", "Sex", "Appearance", "Abort"]
  remaining = ["Name", "Birthday", "Sex", "Appearance"]
  results = {}
  makePlayerLoop = ->
    progress = global.$game.classes.User.prototype.charGen.formatProgress(results)
    prompt = "#{'Character Generation Main Menu'.bold}\n"
    prompt += progress if progress
    prompt += "Things you still must do before you finish: #{remaining.join(', ')}"
    if remaining.length == 0 && options.length == 5
      options.push("Finish")
    global.$game.common.choice socket, prompt, options, (err, option)->
      if option == "Abort" then return global.$game.classes.User.prototype.handleConnection(socket)
      if option == "Finish"
        socket.tell("This is how you're character is going to start:")
        socket.tell global.$game.classes.User.prototype.charGen.formatProgress(results)
        socket.tell "Now they may not be like that forever, but it may take a little doing to make changes after this."
        socket.tell "Are you satisfied with your character? Last chance to say no and make changes..."
        return global.$game.common.yesorno socket, "Continue with creating your character?\n", (stop, go)->
          if (go)
            #make the player
          else
            setTimeout makePlayerLoop, 0
      global.$game.classes.User.prototype.charGen[option] socket, (stats)->
        results[option] = stats
        remaining.remove option
        makePlayerLoop()
  makePlayerLoop()

user.charGen = {} if not user.charGen

user.charGen.Birthday = (socket, callback) ->
  socket.tell("The City of Malice exists in " + "real-time".bold + ", " + "85 years in the future".underline + ", in the Pacific time zone.")
  socket.tell("The current game time is #{global.$game.common.gameTime().format('dddd, MMMM Do, YYYY')}. Please take that into consideration when you give your birthdate. Your character should have an appropriate birth date to reflect the game's timeline.")
  global.$game.common.question socket, "Please enter your birthday in the format: MM/DD/YYYY. So for March 3rd, 2068, you would enter: 3/3/2068.\n", (criteria)->
    moment = require("moment")
    date = moment(criteria.trim(), "MM/DD/YYYY")
    console.log(date.isBefore(moment()))
    return "Please enter a valid birthday." if not date.isValid()
    return "Please enter a birthday after today's date." if date.isBefore(moment())
    before = global.$game.common.gameTime()
    before = before.year(before.year()-18)
    return "please enter a birthday making your character at least 18 years of age." if before.isBefore(date)
  , (err, birthday)->
    moment = require("moment")
    callback(moment(birthday, "MM/DD/YYYY"))


user.charGen.formatProgress = (progress)->
  results = ""
  if progress.Name then results += "Alias: " + progress.Name.alias + "\n"
  if progress.Name then results += "First Name: " + progress.Name.firstName + "\n"
  if progress.Name then results += "Last Name: " + progress.Name.lastName + "\n"
  if progress?.Name?.middleName then results += "Middle Name: " + progress.Name.middleName + "\n"
  if progress.Sex then results += "Sex: " + progress.Sex + "\n"
  if progress.Birthday then results += "Birthday: " + progress.Birthday.format("dddd, MMMM Do, YYYY") + "\n"
  if progress.Appearance then results += "Height: " + progress.Appearance.height + " meters" + " (" + global.$game.constants.player.formatHeight(progress.Appearance.height) + ")" + "\n"
  if progress.Appearance then results += "Weight: " + progress.Appearance.weight + "kg (#{global.$game.constants.player.formatWeight(progress.Appearance.weight, progress.Appearance.height)} for your height)\n"
  if progress.Appearance then results += "Eyes: " + progress.Appearance.eyeStyle + " " + progress.Appearance.eyeColor + " eyes\n"
  if progress.Appearance then results += "Hair: " + progress.Appearance.hairCut + " " + progress.Appearance.hairColor + " " + progress.Appearance.hairStyle + "\n"
  return results

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
  , (err, alias) ->
    global.$game.common.question socket, "Ok. What is their real first name from birth?\n", (criteria)->
      return "Please enter their first name from birth." if criteria.trim().length < 2
    , (err, firstName)->
      global.$game.common.question socket, "Now please enter your last name, or the last name of the mother at birth?\n", (criteria)->
        return "Please enter their last name from birth." if criteria.trim().length < 2
      , (err, lastName)->
        global.$game.common.question socket, "And if they have a middle name, please enter it now, otherwise leave it blank.\n", null, (err, middleName)->
          console.log("ok")
          callback
            alias:alias.trim()
            firstName:firstName.trim()
            lastName:lastName.trim()
            middleName:middleName.trim()

user.charGen.Sex = (socket, callback)->
  q = global.$game.common.question
  sexPrompt = """
What is your characters #{'sex'.bold}
(We're going to keep it simple here, although we do understand sometimes the reality can be a little more complex.)
[M]ale
[F]emale\n
"""
  q socket, sexPrompt, (sex)->
    return "Please, let's keep this straight forward." if not sex.toLowerCase().startsWith("m") and not sex.toLowerCase().startsWith("f")
  , (err, sex) ->
    sex = if sex.toLowerCase().startsWith("m") then "male" else "female"
    callback(sex)

user.charGen.Appearance = (socket, callback) ->
  socket.tell("In The City of Malice, appearances matter. Your health starts with your nutrition, which is a requirement of your weight and height: big people need more food.")
  socket.tell("It's also true that bigger people have a advantage over smaller people, but at the cost of increased nutritional requirements. If you choose to start big, you'll need to do things like eat more often if you want to stay big. In addition, the taller you are, the more weight you'll need to be 'big'.")
  socket.tell("The 'average' weight and height for people is about 1.7 meters and 75 kilograms (or about 6 foot tall and 180 pounds). Deviation from that is at your own peril.")
  q = global.$game.common.question
  heightPrompt = """
What is the #{'height'.bold} of your character? Please answer in meters, between 0.5 and 3.
For example, if your character was 1.8 meters (about 6 feet tall), you would type: 1.8\n
"""
  q socket, heightPrompt, (height) ->
    return "Please enter a number between 0.5 and 3, like 1.8." if isNaN(height) || height < 0.5|| height > 3
  , (err, height) ->
    height = Math.floor(height * 1000) / 1000
    q socket, "That would make you #{global.$game.constants.player.formatHeight(height)}. And your weight in kilograms?\n", (criteria)->
      return "Please enter a number between 15 and 300." if isNaN(parseInt(criteria)) || parseInt(criteria) < 15 || parseInt(criteria) > 300
    , (err, weight)->
      weight = parseInt(weight)
      global.$game.common.choice socket, "That would make you #{global.$game.constants.player.formatWeight(weight, height)} for your height. What would you like your #{'hair cut'.bold} to be?", global.$game.constants.player.hairCut, (err, hairCut)->
        global.$game.common.choice socket, "And the #{'hair style'.bold} to go with your #{hairCut} hair?", global.$game.constants.player.hairStyle, (err, hairStyle)->
          global.$game.common.choice socket, "And is the #{'hair color'.bold} of your #{hairCut} #{hairStyle} hair?", global.$game.constants.player.hairColor, (err, hairColor)->
            global.$game.common.choice socket, "Fine. You have #{hairCut} #{hairColor} #{hairStyle} hair.\nWhat is your #{'eye color'.bold}?", global.$game.constants.player.eyeColor, (err, eyeColor)->
              global.$game.common.choice socket, "Ok, and the #{'eye style'.bold} of these #{eyeColor} eyes?", global.$game.constants.player.eyeStyle, (err, eyeStyle)->
                global.$game.common.choice socket, "Perfect. You've got #{eyeStyle} #{eyeColor} eyes. Let's talk about your #{'skin'.bold}. How would you describe it?", global.$game.constants.player.skinStyle, (err, skinStyle)->
                  global.$game.common.choice socket, "Great. And what's the #{'skin color'.bold} of your #{skinStyle}?", global.$game.constants.player.skinColor, (err, skinColor)->
                    callback
                      height:height,
                      weight:weight,
                      hairCut:hairCut,
                      hairColor:hairColor,
                      hairStyle:hairStyle,
                      eyeColor:eyeColor,
                      eyeStyle:eyeStyle,
                      skinColor:skinColor,
                      skinStyle:skinStyle





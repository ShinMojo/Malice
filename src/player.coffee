
global.$game.$index = {} if not global.$game.$index
global.$game.$index.players = {} if not global.$game.$index.players
global.$game.constants = {} if not global.$game.constants
global.$game.constants.player = {} if not global.$game.constants.player

pc = global.$game.constants.player

pc.maxHeight = 3
pc.height = ["microscopic", "dwarf-sized", "tiny", "diminutive", "petite", "puny", "very short", "short", "average", "slightly tall", "sizable", "tall", "very tall", "extremely tall", "giant", "sky-scraping"]
pc.hairCut = ["bald", "balding", "cropped", "crew-cut", "buzzed", "flat-top", "mohawk", "bihawk", "fauxhawk", "devil lock", "shaved", "faded", "long", "shoulder-length", "layered",  "business", "comb-over", "plugged", "uneven", "bobed", "pixied"]
pc.hairStyle = ["", "curly", "straight", "wavey", "crimped", "messy", "permed", "dreaded", "unkempt", "neat", "tousled", "greasy", "gnarled", "french-twisted", "bun-curled", "spikey", "uncombed", "lifeless", "bouncy", "sparkly"]
pc.hairColor = ["black", "brown", "light brown", "dark brown", "blonde", "dirty blonde", "strawberry blonde", "auburn", "red", "ginger", "blue", "green", "purple", "pink", "orange", "burgundy", "indigo", "violet", "gray", "white", "platinum", "silver"]
pc.eyeColor = ["black", "blue", "red", "green", "emerald", "hazel", "brown", "yellow", "purple", "violet", "indigo", "orange", "pink"]
pc.eyeStyle = ["", "hooded", "blood-shot", "squinty", "round", "wide", "big", "small", "slanty", "scarred", "swollen", "puffy", "dark-rimmed", "bulging", "shifty", "doey", "aggressive", "submissive", "assertive", "defiant"]
pc.skinStyle = ["scarred", "porcelain", "flawless", "smooth", "rough", "sickly", "pasty", "sweaty", "smelly", "flaking", "calloused", "tattooed", "branded", "soft", "furry", "hairy", "hairless", "bruised", "vainy", "acne-ridden", "thin"]
pc.skinColor = ["albino", "ivory", "pale", "white", "tan", "peach", "olive", "jaundiced", "mocha", "rosy", "brown", "dark", "black", "green", "orange", "grey", "ashen", "sun-burnt", "red"]
pc.build = ["athletic", "average", "wide", "skinny", "husky", "fluffy", "big", "large", "enormous"]
pc.strengh = ["disabled", "anemic", "feeble", "frail", "delicate", "weak", "average", "fit", "athletic", "strong", "beefy", "muscular", "built", "tank", "god-like"]
pc.endurance = ["lifeless", "nuclear"]
pc.charisma = [""]
pc.perception = [""]
pc.intelligence = [""]
pc.agility = [""]
pc.luck = [""]

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
  @info = {}

player.moveTo = global.$game.common.moveTo

player.tell = (what)->
  @user.tell(what);

player.walkThrough = (exit) ->
  exit.accept(this)

player.getSex = ->
  @info.sex || "Unknown"

player.getHeight = ->
  @info.height || 0

player.getHeightString = ->
  return global.$game.constants.player.height.proportionate @info.height || 0, global.$game.constants.player.maxHeight
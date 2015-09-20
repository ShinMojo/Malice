
global.$game.$index = {} if not global.$game.$index
global.$game.$index.players = {} if not global.$game.$index.players
global.$game.constants = {} if not global.$game.constants
global.$game.constants.player = {} if not global.$game.constants.player

pc = global.$game.constants.player

pc.maxHeight = 3
pc.maxStat = 100
pc.maxStatOver = 125
pc.weight = ["emaciated", "anorexic", "starving", "sickley", "thin", "under-weight", "average", "a little thick", "big-boned", "thick", "over-weight", "chubby", "portly", "fluffy", "fat", "obese", "massive", "a small planet"]
pc.height = ["non-existent", "microscopic", "itty-bitty", "dwarf-sized", "tiny", "diminutive", "petite", "puny", "very short", "short", "average", "slightly tall", "sizable", "pretty tall", "tall", "very tall", "extremely tall", "incredibly tall", "giant", "sky-scraping"]
pc.hairCut = ["bald", "balding", "cropped", "crew-cut", "buzzed", "flat-top", "mohawk", "bihawk", "fauxhawk", "devil lock", "shaved", "under-cut", "faded", "long", "shoulder-length", "layered",  "business", "comb-over", "plugged", "uneven", "bobed", "pixied"]
pc.hairStyle = ["curly", "straight", "wavy", "crimped", "messy", "permed", "dreaded", "unkempt", "neat", "tousled", "greasy", "gnarled", "french-twisted", "bun-curled", "spikey", "uncombed", "lifeless", "bouncy", "sparkly"]
pc.hairColor = ["black", "brown", "light brown", "dark brown", "blonde", "dirty blonde", "strawberry blonde", "auburn", "red", "ginger", "blue", "green", "purple", "pink", "orange", "burgundy", "indigo", "violet", "gray", "white", "platinum", "silver"]
pc.eyeColor = ["black", "blue", "red", "green", "emerald", "hazel", "brown", "yellow", "purple", "violet", "indigo", "orange", "pink"]
pc.eyeStyle = ["hooded", "blood-shot", "squinty", "round", "wide", "big", "small", "slanty", "scarred", "swollen", "puffy", "dark-rimmed", "bulging", "shifty", "doey", "aggressive", "submissive", "assertive", "defiant"]
pc.skinStyle = ["scarred", "porcelain", "flawless", "smooth", "rough", "sickly", "pasty", "sweaty", "smelly", "flaking", "calloused", "tattooed", "branded", "soft", "furry", "hairy", "hairless", "bruised", "vainy", "acne-ridden", "thin"]
pc.skinColor = ["albino", "ivory", "pale", "white", "tan", "peach", "olive", "jaundiced", "mocha", "rosy", "brown", "dark", "black", "green", "orange", "grey", "ashen", "sun-burnt", "red"]
pc.strengh = ["disabled", "anemic", "feeble", "frail", "delicate", "weak", "average", "fit", "athletic", "strong", "beefy", "muscular", "built", "tank", "super-human", "god-like"]
pc.endurance = ["cadaverous", "wasted", "pathetic", "quickly spent", "sub-standard", "medicore", "sufficent", "reasonable", "above par", "healthy", "sound", "robust", "vigorous", "energetic", "powerful", "machine-like", "nuclear", "eternal"]
pc.charisma = ["disgusting", "ugly", "rude", "awkward", "socially inept", "unpleasant", "tolerable", "bland", "agreeable", "pleasant", "nice", "interesting", "charming", "fascinating", "seductive", "dazzling", "prophet", "cult leader", "politician"]
pc.perception = ["oblivious", "half-asleep", "easily distracted", "day dreamer", "aware", "alert", "perceptive", "attentive", "acute", "keen", "eagle-eyed", "clairvoyant"]
pc.intelligence = ["brain-dead", "dim-witted", "stupid", "ignorant", "dull", "slow", "functional", "smart", "clever", "sharp", "brilliant", "genius", "rocket scientist", "supercomputer", "AI"]
pc.agility = ["useless", "sloth-like", "slow", "delayed", "adequate", "dexterous", "agile", "deft", "nimble", "quick", "cat-like", "fast", "ninja", "speeding bullet", "light-speed"]
pc.luck = ["non-existant", "doomed", "terrible", "unfortunate", "not the best", "not an issue", "better than some", "better than most", "uncanny", "great", "charmed", "on a streak", "unstoppable", "favored by deities", "so good you can't possibly go wrong"]


pc.formatHeight = (height)->
  global.$game.constants.player.height.proportionate(height, global.$game.constants.player.maxHeight)

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
  @info.sex || "Unsexed"

player.getHeight = ->
  @info.height || 0

player.getHeightString = ->
  return global.$game.constants.player.@info.height || 0, global.$game.constants.player.maxHeight
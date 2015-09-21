require("./dist/proportionate.js")

global.$game.$index = {} if not global.$game.$index
global.$game.$index.players = {} if not global.$game.$index.players
global.$game.constants = {} if not global.$game.constants
global.$game.constants.player = {} if not global.$game.constants.player

pc = global.$game.constants.player

pc.maxHeight = 3
pc.maxStat = 100
pc.maxStatOver = 125
pc.weight = ["emaciated", "anorexic", "starving", "sickley", "thin", "under-weight", "lean", "fit", "average", "a little thick", "big-boned", "flabby", "thick", "over-weight", "chubby", "portly", "fluffy", "fat", "obese", "massive", "a small planet"]
pc.height = ["non-existent", "microscopic", "itty-bitty", "dwarf-sized", "tiny", "diminutive", "petite", "puny", "very short", "short", "average", "slightly tall", "sizable", "pretty tall", "tall", "very tall", "extremely tall", "incredibly tall", "giant", "sky-scraping"]
pc.hairCut = ["bald", "balding", "cropped", "crew-cut", "buzzed", "flat-top", "mohawk", "bihawk", "fauxhawk", "devil lock", "shaved", "under-cut", "faded", "long", "shoulder-length", "layered",  "business", "comb-over", "plugged", "uneven", "bobed", "pixied"]
pc.hairStyle = ["curly", "pig-tails", "pony-tails", "straight", "wavy", "crimped", "messy", "permed", "dreaded", "unkempt", "neat", "tousled", "greasy", "gnarled", "french-twisted", "bun-curled", "spikey", "uncombed", "lifeless", "bouncy", "sparkly"]
pc.hairColor = ["black", "brown", "light brown", "dark brown", "blonde", "dirty blonde", "strawberry blonde", "auburn", "red", "ginger", "blue", "green", "purple", "pink", "orange", "burgundy", "indigo", "violet", "gray", "white", "platinum", "silver"]
pc.eyeColor = ["black", "blue", "red", "green", "emerald", "hazel", "brown", "yellow", "purple", "violet", "indigo", "orange", "pink"]
pc.eyeStyle = ["hooded", "blood-shot", "squinty", "round", "wide", "big", "small", "slanty", "scarred", "swollen", "puffy", "dark-rimmed", "bulging", "shifty", "doey", "aggressive", "submissive", "assertive", "defiant"]
pc.skinStyle = ["scarred", "porcelain", "flawless", "smooth", "rough", "sickly", "pasty", "sweaty", "smelly", "flaking", "calloused", "tattooed", "branded", "soft", "furry", "hairy", "hairless", "bruised", "vainy", "acne-ridden", "thin"]
pc.skinColor = ["albino", "ivory", "pale", "white", "tan", "peach", "olive", "jaundiced", "mocha", "rosy", "brown", "dark", "black", "green", "orange", "grey", "ashen", "sun-burnt", "red"]
pc.stats = {} if not pc.stats
pc.stats.strengh = ["handicapped", "anemic", "feeble", "frail", "delicate", "weak", "average", "fit", "athletic", "strong", "beefy", "muscular", "built", "tank", "super-human", "god-like"]
pc.stats.endurance = ["cadaverous", "wasted", "pathetic", "quickly spent", "sub-standard", "medicore", "sufficient", "reasonable", "above par", "healthy", "sound", "robust", "vigorous", "energetic", "powerful", "machine-like", "nuclear", "eternal"]
pc.stats.charisma = ["disgusting", "ugly", "rude", "awkward", "socially inept", "unpleasant", "tolerable", "bland", "agreeable", "pleasant", "nice", "interesting", "charming", "fascinating", "seductive", "dazzling", "prophet", "cult leader", "politician"]
pc.stats.perception = ["oblivious", "half-asleep", "easily distracted", "day dreamer", "aware", "alert", "perceptive", "attentive", "acute", "keen", "eagle-eyed", "clairvoyant"]
pc.stats.intelligence = ["brain-dead", "dim-witted", "stupid", "ignorant", "dull", "slow", "functional", "smart", "clever", "sharp", "brilliant", "genius", "rocket scientist", "supercomputer", "AI"]
pc.stats.agility = ["useless", "sloth-like", "slow", "delayed", "adequate", "dexterous", "agile", "deft", "nimble", "quick", "cat-like", "fast", "ninja", "speeding bullet", "light-speed"]
pc.stats.luck = ["non-existant", "doomed", "terrible", "unfortunate", "not the best", "not an issue", "better than some", "better than most", "uncanny", "great", "charmed", "on a streak", "unstoppable", "favored by deities", "so good you can't possibly go wrong"]


pc.formatHeight = (height)->
  console.log(global.$game.constants.player.height.proportionate)
  global.$game.constants.player.height.proportionate(height, global.$game.constants.player.maxHeight)

pc.formatWeight = (weight, height = 1.8)->
  return global.$game.constants.player.weight.proportionate(weight, 100 * height)

if not global.$game.classes.Player
  global.$game.classes.Player = class Player
    constructor:->
      @type = "$game.classes.Player"
      this.init.apply(this, arguments)

player = global.$game.classes.Player.prototype

player.init = (@name, @user, @location = global.$game.$index.rooms.$nowhere) ->
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
  @info.sex || "female"

player.getHeight = ->
  @info.height || 1.8

player.getWeight = ->
  @info.weight || 80

player.getHeightString = ->
  return global.$game.constants.player.formatHeight @info?.appearance?.height || 0

player.getWeightString = ->
  return global.$game.constants.player.formatWeight @info?.appearance?.weight || 80, @info?.appearance?.height || 1.8
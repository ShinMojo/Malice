global.$game.constants.HumanBody.coverageAreas = [
  "head"
  "scalp"
  "mouth"
  "throat"
  "neck"
  "left eye"
  "right eye"
  "nose"
  "right ear"
  "left ear"
  "left shoulder"
  "right shoulder"
  "left arm"
  "right arm"
  "left forearm"
  "right forearm"
  "left hand"
  "right hand"
  "left thumb"
  "right thumb"
  "left index finger"
  "right index finger"
  "left middle finger"
  "right middle finger"
  "left ring finger"
  "right ring finger"
  "left pinky finger"
  "right pinky finger"
  "groin"
  "left thigh"
  "right thigh"
  "left knee"
  "right knee"
  "left leg"
  "right leg"
  "left foot"
  "right foot"
]

if not global.$game.classes.BodyPart
  global.$game.classes.BodyPart = class BodyPart
    constructor:->
      @type="$game.classes.BodyPart"
      this.init.apply(this, arguments)

part = global.$game.classes.BodyPart.prototype

part.init = (@name, @bones, @removable, @critical, @parts)->
  @condition = {}
  @wearing = []
  @contents = []

part.findPart = (name)->
  return this if name == @name || name.test?(@name)
  require("underscore").find @parts, (part)->
    part.findPart(name)

part.isEmpty = ->
  return if @contents?.length || 0 > 1 then false else true

global.$game.common.makeBodyPart = (name, bones = [], removable = false, critical = false, parts={})->
  new global.$game.classes.BodyPart name, bones, removable, critica, parts

global.$game.common.makeHead = ->
  makeBodyPart = global.$game.common.makeBodyPart
  makeBodyPart("head", ["skull", "jaw", "teeth"], true, true,
    scalp:makeBodyPart "scalp", [], false, false
    throat:makeBodyPart "throat", [], false, true
    neck:makeBodyPart "neck" ["spine"], false, true
    rightEar:makeBodyPart "right ear", [], true, false
    leftEar:makeBodyPart "left ear", [], true, false
    face:makeBodyPart "face", [], false, false,
      leftEye:makeBodyPart "left eye", [], true, false
      rightEye:makeBodyPart "right eye", [], true, false
      mouth:makeBodyPart "mouth", [], false, false
      nose:makeBodyPart "nose", [], true, false

global.$game.common.makeArm = (leftOrRight)->
  makeBodyPart = global.$game.common.makeBodyPart
  makeBodyPart leftOrRight + " shoulder", ["clavical", "scapula"], false, false,
    arm:makeBodyPart leftOrRight + " arm", ["humerus"], true, false,
      forearm:makeBodyPart leftOrRight + " forearm", ["radius", "ulna"], true, false,
        hand:makeBodyPart leftOrRight + " hand", ["wrist"], true, false,
          thumb:makeBodyPart leftOrRight + " thumb", ["metacarpals", "phalanges"], true
          index:makeBodyPart leftOrRight + " index finger", ["metacarpals", "phalanges"], true
          middle:makeBodyPart leftOrRight + " middle finger", ["metacarpals", "phalanges"], true
          ring:makeBodyPart leftOrRight + " ring finger", ["metacarpals", "phalanges"], true
          pinky:makeBodyPart leftOrRight + " pinky finger", ["metacarpals", "phalanges"], true

global.$game.common.makeLeg = (leftOrRight)->
  makeBodyPart = global.$game.common.makeBodyPart
  makeBodyPart leftOrRight + " thigh", ["femur"], true, false,
    knee:makeBodyPart leftOrRight + " knee", ["knee cap"], true, false,
      leg:makeBodyPart leftOrRight + " leg", ["tibia", "fibula"], true, false,
       foot:makeBodyPart leftOrRight + " foot", ["metatarsus", "metatarsal"], true, false

global.$game.common.makePenis = ->
  makeBodyPart = global.$game.common.makeBodyPart
  makeBodyPart "groin", [], false, false,
    penis:makeBodyPart "penis", [], true, false
    leftTestical:makeBodyPart "left testical", [], true, false
    rightTestical:makeBodyPart "right testical", [], true, false

global.$game.common.makeVagina = ->
  global.$game.common.makeBodyPart "vagina", [], false, false

if not global.$game.classes.HumanBody
  global.$game.classes.HumanBody = class HumanBody
    constructor:->
      @type = "$game.classes.HumanBody"
      this.init.apply(this, arguments)

body = global.$game.classes.HumanBody.prototype

body.init = (@sex = "female", @primaryHand = "right")->
  @torso = global.$game.common.makeBodyPart "torso", ["ribs", "spine"], false, true,
    head:global.$game.common.makeHead()
    rightShoulder:global.$game.common.makeArm("right")
    leftShoulder:global.$game.common.makeArm("left")
    rightThigh:global.$game.common.makeLeg("right")
    leftThigh:global.$game.common.makeLeg("left")
    groin:@sex == "male" ? global.$game.common.makePenis() : global.$game.common.makeVagina()

body.getTorso = ->
  @torso

body.getPart = (name)->
  @getTorso().getPart(name)

body.getHead = ->
  @getTorso().parts.head

body.getRightHand = ->
  @getTorso().parts.rightShoulder.parts.arm.parts.forearm.parts.hand

body.getLeftHand = ->
  @getTorso().parts.leftShoulder?.parts?.arm?.parts?.forearm?.parts?.hand

body.getRightFoot = ->
  @getTorso().parts.rightThigh?.parts?.knee?.parts?.leg?.parts?.foot

body.getLeftFoot = ->
  @getTorso().parts.leftThigh?.parts?.knee?.parts?.leg?.parts?.foot

body.getPrimaryHand = ->
  if primaryHand = "right" then @getRightHand() else @getLeftHand()

body.getSecondaryHand = ->
  if primaryHand = "right" then @getLeftHand() else @getRightHand()

body.getHand = ->
  @getPrimaryHand() || @getSecondaryHand()

body.getBothHands = ->
  [@getPrimaryHand(), @getSecondaryHand()]

body.getFreeHand = ->
  if @getPrimaryHand.isEmpty() then @getPrimaryHand else if @getSecondaryHand().isEmpty() then @getSecondaryHand() else undefined

body.isOneHandEmpty = ->
  @getPrimaryHand().isEmpty() || @getSecondaryHand().isEmpty()

body.isBothHandsEmpty = ->
  @getPrimaryHand().isEmpty() && @getSecondaryHand().isEmpty()

body.holdInHands = (what, callback)->
  return callback("Your hands are full.") if not @isOneHandEmpty
  return callback("That requires both hands to hold.") if what.isTwoHanded?() and not @isBothHandsFree()
  firstHand = @getFreeHand()
  where = firstHand
  if(what.isTwoHanded?())
    secondHand = @getFreeHand()
    secondHand.holding = what
    where = [firstHand, secondHand]
  what.moveTo(where)
  callback null, where


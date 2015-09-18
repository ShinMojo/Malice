game = global.$game
classes = game.classes

if not classes.Room
  classes.Room = class Room
    constructor:->
      @type = "$game.classes.Room"
      this.init.apply(this, arguments)

room = classes.Room.prototype

room.init = (@name, @description, @aliases = [], @contents = [], location = game.rooms.$nowhere) ->
  throw new Error("Rooms must have a name.") if not @name
  throw new Error("Room name must be unique.") if game.$index.rooms[@name]
  this.moveTo(location)
  game.$index.rooms[@name] = this
  @exits = []

room.asSeenBy = (who)->
  return @description

if not game.rooms.$nowhere
  game.rooms.$nowhere = new classes.Room("Nowhere", "Nowhere. Literally. The place where things go when they are not in the game.")

if not classes.RoomExit
  classes.Room = class RoomExit
    constructor:->
      @type = "$game.classes.RoomExit"
      this.init.apply(this, arguments)

exit = classes.RoomExit.prototype

exit.init = (@name, @description, @direction, @leaveMessage, @arriveMessage, @aliases, @destination)
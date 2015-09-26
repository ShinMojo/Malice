global.$game.classes = {} if not global.$game.classes

if not global.$game.classes.Room
  global.$game.classes.Room = class Room
    constructor:->
      @type = "$game.classes.Room"
      this.init.apply(this, arguments)

room = global.$game.classes.Room.prototype
global.$game.$index = {} if not global.$game.$index
global.$game.$index.rooms = {} if !global.$game.$index.rooms

room.init = (@name, @description, @aliases = [], @contents = [], location = global.$game.$index.rooms.$nowhere) ->
  throw new Error("Rooms must have a name.") if not @name
  throw new Error("Room name must be unique.") if global.$game.$index.rooms[@name]
  global.$game.$index.rooms[@name] = this
  @exits = []

room.asSeenBy = (who)->
  return @description

if not global.$game.$index.rooms.$nowhere
  new global.$game.classes.Room("$nowhere", "Nowhere. Literally. The place where things go when they are not in the game.")

global.$game.$index.roomExits = {} if !global.$game.$index.roomExits

if not global.$game.RoomExit
  global.$game.classes.RoomExit = class RoomExit
    constructor:->
      @type = "$game.classes.RoomExit"
      this.init.apply(this, arguments)

exit = global.$game.classes.RoomExit.prototype

exit.init = (@name, @description, @leaveMessage, @arriveMessage, @aliases, @source, @destination)->
  throw new Error("RoomExits must have a name, description, leaveMessage, arriveMessage, aliases, source, and destination.") if not @name && @description && @direction && @leaveMessage && @arriveMessage && @aliases && @source && @destination
  throw new Error("RoomExit names must be unique.") if global.$game.$index.roomExits[@source.name + " -> " + @destination.name + " (" + @name + ")"]
  global.$game.$index.roomExits[@source.name + " -> " + @destination.name + " (" + @name + ")"] = this
  @source.exits.push(this)

exit.accept = (who)->
  who.tell(@leaveMessage)
  who.moveTo(@destination)
  who.tell(@arriveMessage)
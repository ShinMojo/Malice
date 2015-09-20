require('app-module-path').addPath(__dirname + '/dist');
serializer = require('./serialize.js')
loader = require("./loader.js")
watchr = require("watchr")
_ = require('underscore')
repl = require('repl')
fs = require('fs')
require('colors')

global.$driver = {}
global.$game = {}
$driver = global.$driver
$game = global.$game
global.$driver.clients = []
global.$driver.authenticatedUsers = {};
global.$driver.getSocket = (user)->
  global.$driver.authenticatedUsers[user]

Array.prototype.remove = ->
  what = undefined
  a = arguments
  L = a.length
  ax = undefined
  while (L && this.length)
    what = a[--L]
    while ((ax = this.indexOf(what)) != -1)
      this.splice(ax, 1)
  return this

if (typeof String.prototype.startsWith != 'function')
  String.prototype.startsWith = (str)->
    return this.slice(0, str.length) == str

if (typeof String.prototype.endsWith != 'function')
  String.prototype.endsWith = (str)->
    return this.slice(-str.length) == str

global.$driver.save = ->
  state = serializer.serialize(global.$game)
  now = new Date
  year = now.getFullYear().toString()
  month = now.getMonth().toString()
  if(month.length == 1)
    month = "0" + month
  day = now.getDate().toString()
  if(day.length == 1)
    day = "0" + day
  hour = now.getHours().toString()
  if(hour.length == 1)
    hour = "0" + hour
  minute = now.getMinutes().toString()
  if(minute.length == 1)
    minute = "0" + minute
  fs.writeFile 'checkpoints/checkpoint-' + year + "" + month + "" + day + "" + hour + "" + minute + '.json', state
  return

global.$driver.broadcast = (message) ->
  _(global.$driver.clients).each (client) ->
    client.write message + '\n'
    return
  return

global.$driver.load = (filename) ->
  if !filename
    try
      filename = _(fs.readdirSync('checkpoints')).chain().filter((name) ->
        name.indexOf('checkpoint') > -1
      ).sort().reverse().first().value()
    catch e
      console.log e
      return
    if !filename
      return
    try
      data = fs.readFileSync("checkpoints/" + filename)
    catch e
      console.log e
      return
    console.log 'Loading checkpoint from ' + filename + '...'
    try
      global.$game = serializer.unserialize(data.toString())
      console.log 'Checkpoint loaded.'
    catch e
      console.log e
  return

global.$driver.handleNewConnection = (socket) ->
  readline = require("readline")
  rl = readline.createInterface(socket, socket)
  rl.question "Can you see the " + "colors? ".rainbow, (useColor) ->
    if !useColor.toLowerCase().startsWith("n")
      socket.tell = (str)->
        socket.write(str + "\n")
    else
      socket.tell = (str)->
        socket.write(str.strip + "\n")
    rl.close()
    global.$game.common.login.handleNewConnection(socket)

global.$driver.startDriver = ->
  net = require('./telnet.js')
  net.createServer((socket) ->
    socket.do.transmit_binary()
    socket.do.window_size()
    socket.on 'window size', (e) ->
      if e.command == 'sb'
        console.log 'telnet window resized to %d x %d', e.width, e.height
    global.$driver.clients.push socket
    socket.alive = true
    socket.on 'end', ->
      socket.alive = false
      global.$driver.clients.splice global.$driver.clients.indexOf(socket), 1
      delete(global.$driver.authenticatedUsers[socket.user]) if socket.user
    global.$driver.handleNewConnection socket
  ).listen 5555
  console.log 'Server listening at port 5555\n'

global.$driver.load()
global.$driver.startDriver()
global.$game.common.startGame() if global.$game.common.startGame
setInterval global.$driver.save, 1000 * 60 * 10

repl.start(
  prompt: '> ',
  input: process.stdin,
  output: process.stdout,
  useGlobal:true
).on 'exit', ->
  socket.end();

watchr.watch
  paths: ["./dist"],
  listeners:
    change: (changeType,filePath,fileCurrentStat,filePreviousStat) ->
      try
        if filePath.endsWith("driver.js") or filePath.endsWith("loader.js") then return
        console.log("Reloading " + filePath)
        loader.loadSync("./" + filePath)
      catch e
        console.log e

global.process.on('uncaughtException', function (err) {
  console.log(err);
})
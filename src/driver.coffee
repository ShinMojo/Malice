global.$driver = {}
global.$game = {}
$driver = global.$driver
$game = global.$game
fs = require('fs')
global.$driver.clients = []
global.$driver.authenticatedUsers = {};
global.$driver.getSocket = (user)->
  global.$driver.authenticatedUsers[user]
serializer = require('./serialize.js')
_ = require('underscore')
readline = require('readline')
repl = require('repl')

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

global.$driver.order = (obj, ordering) ->
  props = _(Object.getOwnPropertyNames(obj)).filter (item) ->
    ordering.indexOf(item) == -1
  ordered = {}
  ordering.forEach (item) ->
    ordered[item] = obj[item]
  props.forEach (item) ->
    ordered[item] = obj[item]
  ordered

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

global.$driver.emitLines = (stream) ->
  backlog = ''
  stream.on 'data', (data) ->
    backlog += data
    n = backlog.indexOf('\n')
    # got a \n? emit one or more 'line' events
    while ~n
      stream.emit 'line', backlog.substring(0, n)
      backlog = backlog.substring(n + 1)
      n = backlog.indexOf('\n')
    return
  stream.on 'end', ->
    if backlog
      stream.emit 'line', backlog
    return
  return


global.$driver.login = (socket) ->
  rl = readline.createInterface(socket, socket)
  loginPrompt = "Login> ";
  passwordPrompt = "Password> ";
  rl.question(loginPrompt, (login)->
    rl.question(passwordPrompt, (password) ->
      rl.close();
      user = _(global.$game.users).find((user) ->
        return user.name.toLowerCase() == login.toLowerCase()
      )
      return global.$driver.login(socket) if !user
      crypto = require "crypto"
      hash = crypto.createHash "sha256"
      hash.update password
      hash.update user.salt + ""
      if(user.password != hash.digest("hex"))
        return socket.end("Bad login!\n")
      socket.write("Successfully authenticated as " + login + ".\n")
      global.$driver.authenticatedUsers[user] = socket
      socket.user = user
      global.$driver.handleInput(socket)
    );
  );


global.$driver.handleNewConnection = (socket) ->
  global.$driver.login socket

global.$driver.handleInput = (socket) ->
  repl.start(
    prompt: '> ',
    input: socket,
    output: socket,
    useGlobal:true
  ).on 'exit', ->
    socket.end();

global.$driver.startDriver = ->
  net = require('net')
  net.createServer((socket) ->
    global.$driver.clients.push socket
    socket.alive = true
    socket.on 'end', ->
      socket.alive = false
      global.$driver.clients.splice global.$driver.clients.indexOf(socket), 1
      delete(global.$driver.authenticatedUsers[socket.user]) if socket.user
    global.$driver.handleNewConnection socket

  ).listen 5000
  # Put a friendly message on the terminal of the server.
  console.log 'Server listening at port 5000\n'

global.$driver.load()
global.$driver.startDriver()
global.$game.startGame() if global.$game.startGame
setInterval global.$driver.save, 1000 * 60 * 10

repl.start(
  prompt: '> ',
  input: process.stdin,
  output: process.stdout,
  useGlobal:true
).on 'exit', ->
  socket.end();

loader = require("./loader.js")
watchr = require("watchr")

watchr.watch
  paths: ["./dist"],
  listeners:
    change: (changeType,filePath,fileCurrentStat,filePreviousStat) ->
      try
        if filePath.endsWith("driver.js") or filePath.endsWith("loader.js") then return
        console.log("Reloading " + filePath)
        loader.load("./" + filePath)
      catch e
        console.log e









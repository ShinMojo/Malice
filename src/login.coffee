readline = require('readline')

global.$game.login = (socket) ->
  rl = readline.createInterface(socket, socket)
  loginPrompt = "Login> ";
  passwordPrompt = "Password> ";
  rl.question(loginPrompt, (login)->
    if(login.equals("register"))
      rl.close()
      return global.$game.register(socket, ->
        global.$driver.login(socket)
      )
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
      global.$game.handleInput(socket)
    );
  );

global.$game.handleInput = (socket) ->
  repl.start(
    prompt: '> ',
    input: socket,
    output: socket,
    useGlobal:true
  ).on 'exit', ->
    socket.end();
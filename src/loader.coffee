fs=require("fs")
vm = require("vm")

module.exports.testLoad = (name) ->
  m = require('module')
  sandbox = vm.createContext({})
  statement = "require(\"" + name + "\")"
  try
    vm.runInContext(m.wrap(statement), sandbox)(exports, require, module, __filename, __dirname);
    return true
  catch e
    console.log e
    return false



module.exports.load = (name, callback) ->
  module.exports.loadResource((err, resource)->
    callback(vm.runInThisContext(resource))
  )

module.exports.loadSync = (name) ->
  vm.runInThisContext(module.exports.loadResourceSync(name))

module.exports.loadResourceSync = (name) ->
  fs.readFileSync(name).toString()

module.exports.loadResource = (name, callback) ->
  fs.readFile name, (err, data)->
    callback err, data.toString()
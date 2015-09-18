module.exports.testLoad = (name) ->
  vm = require("vm")
  m = require('module')
  sandbox = vm.createContext({})
  statement = "require(\"" + name + "\")"
  try
    vm.runInContext(m.wrap(statement), sandbox)(exports, require, module, __filename, __dirname);
    return true
  catch e
    console.log e
    return false

module.exports.load = (name) ->
  fs = require("fs")
  vm = require("vm")
  code = fs.readFileSync(name)
  vm.runInThisContext(code.toString())

noflo = require 'noflo'

class DoSomething extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

exports.getComponent = -> new DoSomething

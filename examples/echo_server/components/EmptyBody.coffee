noflo = require 'noflo'

class EmptyBody extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'connect', =>
      @group = null

    @inPorts.in.on 'begingroup', (@group) =>
      @outPorts.out.beginGroup @group

    @inPorts.in.on 'data', (data) =>
      if @group is 'body'
        @outPorts.out.send 'empty-body'
      else
        @outPorts.out.send data

    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
      @group = null

    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new EmptyBody

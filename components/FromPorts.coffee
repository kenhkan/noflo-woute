querystring = require 'querystring'
_ = require 'underscore'
noflo = require 'noflo'

class FromPorts extends noflo.Component
  constructor: ->
    @setup()

    @inPorts =
      status: new noflo.Port 'string'
      headers: new noflo.Port 'object'
      body: new noflo.Port 'string'
      reqres: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.reqres.on 'begingroup', (group) =>
      @groups.push group

    @inPorts.status.on 'data', (@status) =>
    @inPorts.headers.on 'data', (headers) =>
      _.extend @headers, headers
    @inPorts.body.on 'data', (body) =>
      @body += body
    @inPorts.reqres.on 'data', (@reqres) =>

    @inPorts.status.on 'disconnect', => @flush()
    @inPorts.headers.on 'disconnect', => @flush()
    @inPorts.body.on 'disconnect', => @flush()
    @inPorts.reqres.on 'disconnect', => @flush()

  flush: ->
    return unless @reqres

    @reqres.res.writeHead @status, @headers
    @reqres.res.write @body

    @outPorts.out.beginGroup group for group in @groups
    @outPorts.out.send @reqres
    @outPorts.out.endGroup() for group in @groups
    @outPorts.out.disconnect()

    @setup()

  setup: ->
    @groups = []
    @status = 200
    @headers = {}
    @body = ''
    @reqres = null

exports.getComponent = -> new FromPorts

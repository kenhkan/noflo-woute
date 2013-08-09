querystring = require 'querystring'
noflo = require 'noflo'
_ = require 'underscore'

class ToPorts extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      url: new noflo.Port 'object'
      headers: new noflo.Port 'object'
      query: new noflo.Port 'object'
      body: new noflo.Port 'object'
      reqres: new noflo.Port 'object'

    @inPorts.in.on 'begingroup', (group) =>
      @sendToAll 'beginGroup', group
    @inPorts.in.on 'endgroup', (group) =>
      @sendToAll 'endGroup', group
    @inPorts.in.on 'disconnect', =>
      @sendToAll 'disconnect'

    @inPorts.in.on 'data', (data) =>
      url = data.req.url.replace /\?.+$/, ''

      if data.req.url.match /\?/
        query = data.req.url.replace /^.+\?/, ''
        query = querystring.parse query
      else
        query = {}

      headers = data.req.headers
      body = data.req.body

      @outPorts.url.send url
      @outPorts.headers.send headers
      @outPorts.query.send query
      @outPorts.body.send body
      @outPorts.reqres.send data

  sendToAll: (operation, packet) ->
    for name, port of @outPorts
      port[operation] packet

exports.getComponent = -> new ToPorts

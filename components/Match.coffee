noflo = require 'noflo'

class Match extends noflo.Component
  constructor: ->
    @matches = null
    @methods = null

    @inPorts =
      in: new noflo.Port 'object'
      match: new noflo.Port 'string'
      method: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'
      fail: new noflo.Port 'object'

    @inPorts.match.on 'data', (match) =>
      @matches ?= []
      @matches.push new RegExp match

    @inPorts.method.on 'data', (method) =>
      @methods ?= []
      @methods.push method.toLowerCase()

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'endgroup', (group) =>
      @outPorts.out.endGroup group
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.in.on 'data', (data) =>
      success = true

      # Match HTTP methods
      if @methods?
        method = data.req.method.toLowerCase()
        success = false unless @methods.indexOf method > -1

      # Match URL
      if @matches
        url = data.req.url.replace (new RegExp('\\?.+$')), ''
        matched = false
        for match in @matches
          matched = true if url.match(match)?
        success = false unless matched

      # If all pass, forward to OUT; FAIL otherwise
      if success
        @outPorts.out.send data
      else
        @outPorts.fail.send data

exports.getComponent = -> new Match

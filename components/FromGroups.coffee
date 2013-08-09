querystring = require 'querystring'
_ = require 'underscore'
noflo = require 'noflo'

class FromGroups extends noflo.Component
  constructor: ->
    @parts = ['status', 'headers', 'body', 'reqres']

    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'connect', =>
      @status = 200
      @group = null
      @reqres = null
      @headers = {}
      @body = ''

    @inPorts.in.on 'disconnect', =>
      @flush()
      @outPorts.out.disconnect()

    @inPorts.in.on 'begingroup', (group) =>
      # Extract relevant parts
      if @parts.indexOf(group) > -1
        @group = group
      # Otherwise, simply forward
      else
        @outPorts.out.beginGroup group

    @inPorts.in.on 'endgroup', (group) =>
      # Only close irrelevant groups
      if group is @group
        @group = null
      else
        @outPorts.out.endGroup group

    @inPorts.in.on 'data', (data) =>
      switch @group
        when 'status'
          @status = data
        when 'headers'
          _.extend @headers, data
        when 'body'
          @body += data
        when 'reqres'
          @reqres = data

  flush: ->
    @reqres.res.writeHead @status, @headers
    @reqres.res.write @body
    @outPorts.out.send @reqres

exports.getComponent = -> new FromGroups

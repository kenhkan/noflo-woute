noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  FromPorts = require '../components/FromPorts.coffee'
else
  FromPorts = require 'woute/components/FromPorts.js'

describe 'FromPorts component', ->
  globals = {}

  beforeEach ->
    globals.c = FromPorts.getComponent()
    globals.status = noflo.internalSocket.createSocket()
    globals.headers = noflo.internalSocket.createSocket()
    globals.body = noflo.internalSocket.createSocket()
    globals.request = noflo.internalSocket.createSocket()
    globals.out = noflo.internalSocket.createSocket()
    globals.c.inPorts.status.attach globals.status
    globals.c.inPorts.headers.attach globals.headers
    globals.c.inPorts.body.attach globals.body
    globals.c.inPorts.request.attach globals.request
    globals.c.outPorts.out.attach globals.out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(globals.c.inPorts.status).to.be.an 'object'
      chai.expect(globals.c.inPorts.headers).to.be.an 'object'
      chai.expect(globals.c.inPorts.body).to.be.an 'object'
      chai.expect(globals.c.inPorts.request).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(globals.c.outPorts.out).to.be.an 'object'

  describe 'construct response from packets from different ports', ->
    beforeEach ->
      globals.statusCode = null
      globals.sentHeaders = {}
      globals.sentBody = ''
      globals.request =
        res:
          _mock: 'response object'
          writeHead: (code, headers) ->
            globals.statusCode = code
            globals.sentHeaders = headers
          write: (chunk) -> globals.sentBody += chunk
        req:
          url: '/login?username=password'
          headers:
            host: 'localhost:1337'
            accept: '*/*'
          body: 'some body'

    it 'applies status code', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.statusCode).to.equal '404'
        done()

      globals.status.connect()
      globals.status.send '404'
      globals.request.connect()
      globals.request.send globals.request
      globals.request.disconnect()
      globals.status.disconnect()

    it 'applies headers', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.sentHeaders).to.deep.equal
          'x-backend': 'noflo'
          'x-frontend': 'browser'
        done()

      globals.headers.connect()
      globals.headers.send
        'x-backend': 'noflo'
      globals.headers.send
        'x-frontend': 'browser'
      globals.request.connect()
      globals.request.send globals.request
      globals.request.disconnect()
      globals.headers.disconnect()

    it 'applies body', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.sentBody).to.equal 'somebody'
        done()

      globals.body.connect()
      globals.body.send 'some'
      globals.body.send 'body'
      globals.request.connect()
      globals.request.send globals.request
      globals.request.disconnect()
      globals.body.disconnect()

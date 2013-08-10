noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  FromGroups = require '../components/FromGroups.coffee'
else
  FromGroups = require 'woute/components/FromGroups.js'

describe 'FromGroups component', ->
  globals = {}

  beforeEach ->
    globals.c = FromGroups.getComponent()
    globals.in = noflo.internalSocket.createSocket()
    globals.out = noflo.internalSocket.createSocket()
    globals.c.inPorts.in.attach globals.in
    globals.c.outPorts.out.attach globals.out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(globals.c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(globals.c.outPorts.out).to.be.an 'object'

  describe 'construct response from grouped packets', ->
    beforeEach ->
      globals.statusCode = null
      globals.headers = {}
      globals.body = ''
      globals.request =
        res:
          _mock: 'response object'
          writeHead: (code, headers) ->
            globals.statusCode = code
            globals.headers = headers
          write: (chunk) -> globals.body += chunk
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

      globals.in.connect()
      globals.in.beginGroup 'status'
      globals.in.send '404'
      globals.in.endGroup 'status'
      globals.in.beginGroup 'request'
      globals.in.send globals.request
      globals.in.endGroup 'request'
      globals.in.disconnect()

    it 'applies headers', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.headers).to.deep.equal
          'x-backend': 'noflo'
          'x-frontend': 'browser'
        done()

      globals.in.connect()
      globals.in.beginGroup 'headers'
      globals.in.send
        'x-backend': 'noflo'
      globals.in.send
        'x-frontend': 'browser'
      globals.in.endGroup 'headers'
      globals.in.beginGroup 'request'
      globals.in.send globals.request
      globals.in.endGroup 'request'
      globals.in.disconnect()

    it 'applies body', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.body).to.equal 'somebody'
        done()

      globals.in.connect()
      globals.in.beginGroup 'body'
      globals.in.send 'some'
      globals.in.send 'body'
      globals.in.endGroup 'body'
      globals.in.beginGroup 'request'
      globals.in.send globals.request
      globals.in.endGroup 'request'
      globals.in.disconnect()

    it 'does not need to receive request/response object last if it is within the same connection', (done) ->
      globals.out.on 'disconnect', ->
        chai.expect(globals.body).to.equal 'somebody'
        done()

      globals.in.connect()
      globals.in.beginGroup 'request'
      globals.in.send globals.request
      globals.in.endGroup 'request'
      globals.in.beginGroup 'body'
      globals.in.send 'some'
      globals.in.send 'body'
      globals.in.endGroup 'body'
      globals.in.disconnect()

noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Match = require '../components/Match.coffee'
else
  Match = require 'woute/components/Match.js'

describe 'Match component', ->
  globals = {}

  beforeEach ->
    globals.c = Match.getComponent()
    globals.in = noflo.internalSocket.createSocket()
    globals.match = noflo.internalSocket.createSocket()
    globals.method = noflo.internalSocket.createSocket()
    globals.out = noflo.internalSocket.createSocket()
    globals.fail = noflo.internalSocket.createSocket()
    globals.c.inPorts.in.attach globals.in
    globals.c.inPorts.match.attach globals.match
    globals.c.inPorts.method.attach globals.method
    globals.c.outPorts.out.attach globals.out
    globals.c.outPorts.fail.attach globals.fail

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(globals.c.inPorts.in).to.be.an 'object'
      chai.expect(globals.c.inPorts.match).to.be.an 'object'
      chai.expect(globals.c.inPorts.method).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(globals.c.outPorts.out).to.be.an 'object'
      chai.expect(globals.c.outPorts.fail).to.be.an 'object'

  describe 'matching', ->
    it 'always matches', (done) ->
      request =
        req:
          url: '/login'
          method: 'GET'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.in.send request

    it 'matches specific URL', (done) ->
      request =
        req:
          url: '/login?username=password'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.match.send 'login'
      globals.in.send request

    it 'matches multiple URLs', (done) ->
      request =
        req:
          url: '/login'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      # With or without slash
      globals.match.send '/login'
      globals.match.send '/echo'
      globals.in.send request

    it 'matches all HTTP methods by default', (done) ->
      request =
        req:
          url: '/login'
          method: 'PUT'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.match.send 'login'
      globals.in.send request

    it 'matches specific HTTP method', (done) ->
      request =
        req:
          method: 'POST'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.method.send 'post'
      globals.in.send request

    it 'fails on non-matching method', (done) ->
      request =
        req:
          method: 'POST'

      globals.fail.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.method.send 'get'
      globals.in.send request

    it 'matches multiple HTTP methods', (done) ->
      request =
        req:
          method: 'POST'

      globals.out.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.method.send 'post'
      globals.method.send 'put'
      globals.in.send request

    it 'does not match', (done) ->
      request =
        req:
          url: '/logout'

      globals.fail.on 'data', (data) ->
        chai.expect(data).to.deep.equal request
        done()

      globals.match.send 'login'
      globals.in.send request

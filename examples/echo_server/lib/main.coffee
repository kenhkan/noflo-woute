fs = require 'fs'
noflo = require 'noflo'

fs.readFile './graphs/main.fbp', (err, data) ->
  throw err if err
  fbp = data.toString()

  noflo.graph.loadFBP fbp, (graph) ->
    noflo.createNetwork graph, (network) ->
      console.log 'Network is ready'

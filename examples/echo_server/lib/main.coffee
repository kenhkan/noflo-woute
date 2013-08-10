noflo = require 'noflo'

port = '1337'
fbp = """
  # Setup the webserver
  '#{port}' -> LISTEN Server(webserver/Server)
  Output(core/Merge) OUT -> IN SendResponse(webserver/SendResponse)

  # Define some matching rules
  'post' -> METHOD MatchAllPosts(woute/Match)
  '/echo' -> MATCH MatchEcho(woute/Match)
  '/noop' -> MATCH MatchNoop(woute/Match)

  # The order of the matchers here determins which path gets priority in
  # matching
  Server() REQUEST -> IN MatchAllPosts() FAIL -> IN MatchEcho() FAIL -> IN MatchNoop() FAIL -> IN MatchMissing(woute/Match) FAIL -> IN ThisIsNeverReached(core/Output)

  # 404
  '404' -> STRING SendMissingStatus(strings/SendString)
  MatchMissing() OUT -> IN MissingToPorts(woute/ToPorts)
  MissingToPorts() URL -> IN SendMissingStatus() OUT -> STATUS MissingFromPorts(woute/FromPorts)
  MissingToPorts() REQRES -> REQRES MissingFromPorts() OUT -> IN Output()
"""

noflo.graph.loadFBP fbp, (graph) ->
  noflo.createNetwork graph, (network) ->
    console.log 'Network is ready'

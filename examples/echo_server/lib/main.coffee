noflo = require 'noflo'

port = '1337'
fbp = """
  # Setup the webserver

  '#{port}' -> LISTEN Server(webserver/Server) REQUEST -> IN BodyParser(webserver/BodyParser)
  Output(core/Merge) OUT -> IN SendResponse(webserver/SendResponse)

  # Match by HTTP verbs (GET, POST, etc)

  'post' -> METHOD MatchAllPosts(woute/Match)

  # Match by URL segments

  '/echo' -> MATCH MatchEcho(woute/Match)
  '/noop' -> MATCH MatchNoop(woute/Match)

  # The order of the matchers here determins which path gets priority in
  # matching

  BodyParser() OUT -> IN MatchAllPosts() FAIL -> IN MatchEcho() FAIL -> IN MatchNoop() FAIL -> IN MatchMissing(woute/Match) FAIL -> IN ThisIsNeverReached(core/Output)

  # Example of showing and returning the body of a POST request

  MatchAllPosts() OUT -> IN PostsToPorts(woute/ToPorts)
  PostsToPorts() BODY -> IN PrintPostsBody(core/Output) OUT -> IN JsonifyPostsBody(strings/Jsonify) OUT -> BODY PostsFromPorts(woute/FromPorts)
  PostsToPorts() REQRES -> REQRES PostsFromPorts() OUT -> IN Output()

  # Return with "Not Found" otherwise

  '404' -> STRING SendMissingStatus(strings/SendString)
  MatchMissing() OUT -> IN MissingToPorts(woute/ToPorts)
  MissingToPorts() URL -> IN SendMissingStatus() OUT -> STATUS MissingFromPorts(woute/FromPorts)
  MissingToPorts() REQRES -> REQRES MissingFromPorts() OUT -> IN Output()
"""

noflo.graph.loadFBP fbp, (graph) ->
  noflo.createNetwork graph, (network) ->
    console.log 'Network is ready'

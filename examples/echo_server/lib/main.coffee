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
  '/empty-body' -> MATCH MatchEmptyBody(woute/Match)

  # The order of the matchers here determins which path gets priority in
  # matching

  BodyParser() OUT -> IN MatchEcho() FAIL -> IN MatchEmptyBody() FAIL -> IN MatchAllPosts() FAIL -> IN MatchMissing(woute/Match) FAIL -> IN ThisIsNeverReached(core/Output)

  # Example of printing the body of a POST request

  MatchAllPosts() OUT -> IN PostsToPorts(woute/ToPorts)
  PostsToPorts() BODY -> IN PrintPostsBody(core/Output)
  PostsToPorts() REQRES -> REQRES PostsFromPorts(woute/FromPorts) OUT -> IN Output()

  # Example of echoing incoming HTTP request

  MatchEcho() OUT -> IN EchoToPorts(woute/ToPorts)
  EchoToPorts() BODY -> IN JsonifyBody(strings/Jsonify) OUT -> BODY EchoFromPorts(woute/FromPorts)
  EchoToPorts() REQRES -> REQRES EchoFromPorts() OUT -> IN Output()

  # Example of use case of FromGroups/ToGroups: for components that
  # directly act on the incoming request

  MatchEmptyBody() OUT -> IN EchoToGroups(woute/ToGroups) OUT -> IN EmptyBody(echo/EmptyBody) OUT -> IN EchoFromGroups(woute/FromGroups) OUT -> IN Output()

  # Return with "Not Found" otherwise

  '404' -> STRING SendMissingStatus(strings/SendString)
  MatchMissing() OUT -> IN MissingToPorts(woute/ToPorts)
  MissingToPorts() URL -> IN SendMissingStatus() OUT -> STATUS MissingFromPorts(woute/FromPorts)
  MissingToPorts() REQRES -> REQRES MissingFromPorts() OUT -> IN Output()
"""

noflo.graph.loadFBP fbp, (graph) ->
  noflo.createNetwork graph, (network) ->
    console.log 'Network is ready'

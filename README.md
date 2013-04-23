Routing web requests based on the request's URL [![Build Status](https://secure.travis-ci.org/kenhkan/noflo-woute.png?branch=master)](https://travis-ci.org/kenhkan/noflo-woute)
===============================

Most of the time you want to define a bunch of URL patterns and provide
a handler for each of them, not unlike
[Sinatra](http://www.sinatrarb.com/). With Woute, you can route web
requests similar to Sintra! You simply send in an array of URL patterns
and attach handler components to it.


API
-------------------------------

Note: All the following examples are written in FBP.

First, set up a Woute server with an array of URL patterns, which is
based on [noflo-webserver](https://github.com/bergie/noflo-webserver):

    '8080' -> LISTEN Woute(Woute)
    ',' -> DELIMITER SplitStr()
    'a/b.+,a/c,.+' -> IN SplitStr() OUT -> ROUTES Woute()

Routes are defined *at once*. The second time Woute's 'ROUTES' port
receives something, all routes would be replaced. Each data IP
represents one pattern to match.

Routes are RegExp strings that have an implied '^', meaning that the URL
must match from the beginning onward. In the example above, 'a/b.+'
matches only URL starting with 'a' then followed by any string starting
with 'b', and followed by anything afterwards. '.+' would simply match
anything that is not empty (i.e. the "home page").

Each route is then coupled with a handler that attaches to the 'OUT'
port of Woute. Coupling is done by *position* of attachment. For
instance, continuing from the above:

    Woute() OUT -> IN AB(Output)
    Woute() OUT -> IN AC(Output)
    Woute() OUT -> IN Any(Output)

If the definition is somewhat juggled around, however, like:

    'a/b.+,.+,a/c' -> IN SplitStr() OUT -> ROUTES Woute(Woute)

Then you would have to write the FBP program as:

    Woute() OUT -> IN AB(Output)
    Woute() OUT -> IN Any(Output)
    Woute() OUT -> IN AC(Output)

Note: placing a '.+' route would render any routes after it never to be
reached, except of course '.\*' or ''.

Any unmatched requests are simply ignored. Therefore, it is advised to
have a '.\*' at the end of your route definition.

#### What is passed on?

The handler with a matching URL would receive a truncated URL starting
from the end of the matched portion of the URL as well as the headers
and body of the request.

If the request looks like:

    GET /a/cat/something/here HTTP/1.1
    Host: example.com
    Content-Type: application/json; charset=utf-8
    Content-Length: 23

    {
      "Transaction": "OK"
    }

The handler 'AC', in the first example, would then receive:

    GROUP: session-id
      DATA: <SomeRandomSessionIDHere>
    GROUP: url
      DATA: something
      DATA: here
    GROUP: headers
      GROUP: host
        DATA: example.com
      GROUP: content-type
        DATA: application/json; charset=utf-8
      GROUP: content-length
        DATA: 23
    GROUP: body
      DATA: {\n  "Transaction": "Is it OK?"\n}

#### Sending back a response

Woute never exposes the response object. It much prefers you to pass
back the data to respond to the client and let it handle the rest for
you. The session ID is the key that you must retain and return along
with the response for Woute to work its magic.

An example would be:

    GROUP: session-id
      DATA: <TheGivenSessionIDHere>
    GROUP: headers
      GROUP: some-return-header
        DATA: some-header-data
    GROUP: body
      DATA: {\n  "Transaction": "Yes, it is OK."\n}

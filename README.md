# Routing web requests based on the request's URL [![Build Status](https://secure.travis-ci.org/kenhkan/noflo-woute.png?branch=master)](https://travis-ci.org/kenhkan/noflo-woute)

The most natural way to route web requests is to use matching rules, not
unlike [Sinatra](http://www.sinatrarb.com/) in Ruby and
[Express](http://expressjs.com/) in JavaScript.

However, in NoFlo, it's a network of blackboxes you connect to make a
program. The intuitive way is to connect incoming requests to a series
of matchers; failure to match runs onto the next matcher until there is
no match, in which case a "404" box is sent the request.

When successful matches occur, the request is sent to wherever the
programmer wants, which hopefully produces some result to be sent to a
responder. An abstract example would be:

    
                          /login                /get_images
                            +                      +
                            |                      |
                            |                      |
   +-----------+        +---v-------+         +----v------+           +------------+
   |           |        |           |         |           |           |            |
   |           |  Req   |  First    |  Fail   |  Second   |  Fail     |  Third     |
   | Webserver +-------->  Matcher  +--------->  Matcher  +----------->  Matcher   |
   |           |        |           |         |           |           |            |
   +-----------+        +---+-------+         +----+------+           +---+--------+
                            |                      |                      |
                            |Success               |Success               |Success
                            |                      |                      |
                        +---v-------+         +----v------+           +---v--------+
                        |           |         |           |           |            |
                        |           |         |           |           |            |
                        |           |         | Fetch     |           |            |
                        | Login     |         | Images    |           | 404        |
                        |           |         |           |           |            |
                        +-----+-----+         +----+------+           +---+--------+
                              |                    |                      |
                              |                    |Res                   |
                              |Res                 |                      |Res
                              |               +----v------+               |
                              |               |           |               |
                              +--------------->           <---------------+
                                              | Respond   |
                                              |           |
                                              +-----------+


## Installation

    npm install --save noflo-woute


## Quick & Dirty Usage

To use noflo-woute in its most basic form, you only need the 'Matcher'
component:

* Inport 'MATCH': *optional* takes a URL segment to match. Default to
  always match
* Inport 'METHOD': *optional* an HTTP method. Default to 'GET'
* Inport 'IN': takes a request/response pair produced by
  [noflo-webserver](https://github.com/noflo/noflo-webserver)
* Outport 'OUT': the request/repsonse pair if match is successful
* Outport 'FAIL': if match is unsuccessful, most likely attached to
  another matcher

Simply connect some matchers together like the abstract example shown
above.


## Adapters

Matchers are agnostic to the actual request/response, meaning that
whoever handling a successfully matched case is handed the same thing
that they would get from noflo-webserver. Two adapter components are
there to help you to "split" the request into different parts so
manipulation is easier: 'woute/ToGroups' and 'woute/ToPorts'.

Both adapters break the request/response object into these areas:

* url: ditto
* headers: the HTTP headers broken down into pairs
* query: the query string broken down into pairs
* body: the body passed through as-is (i.e. always a string)
* response: the response object

'ToGroups' converts the outcoming request/response object into the
listed areas grouped by the names. 'ToPorts' converts the object into
the areas via ports by those names.

For instance, out comes from port 'ToGroups' within a single connection:

    BEGINGROUP: URL
    DATA: /login
    ENDGROUP: URL
    BEGINGROUP: HEADERS
    DATA: { "x-http-destination": "NoFlo Awesomeness" }
    ENDGROUP: HEADERS
    BEGINGROUP: QUERY
    DATA: { this: "is sent", as: "an object" }
    ENDGROUP: QUERY
    BEGINGROUP: BODY
    DATA: {"this":[{"is":"JSON","but":"is"},{"still":"sent"}],"as":"a string"}
    ENDGROUP: BODY
    BEGINGROUP: RESPONSE
    DATA: <The response object>
    ENDGROUP: RESPONSE

For 'ToPorts', the same data packets would be sent to ports 'URL',
'HEADERS', 'QUERY', 'BODY', and 'RESPONSE', respectively. However,
because now the response is disassociated from the request, we need to
somehow link them to reassemble them before sending the response back.
To resolve that issue, data packets for each port are enclosed by a
group in the format of `response-id:<SomeRandomIdHere>`.

### Putting things back

When you are done and are ready to send back a response, remember to
feed your content to their counterparts: 'woute/FromGroups' and
'woute/FromPorts'. These two components take the disassembled data
packets and splice them back into a request/response object so it's
ready to be sent to
[webserver/SendResponse](https://github.com/noflo/noflo-webserver/blob/master/components/SendResponse.coffee).

The components take these types of data packets:

* headers: the response headers to be sent back
* body: the body to be sent back
* response: the response object

Note the *all* these need to be sent back for reassembly to take place.

### Notes

Remember to apply any desired
[middleware](https://github.com/noflo/noflo-webserver/tree/master/components)
before passing the request/response object from webserver to any
matcher.

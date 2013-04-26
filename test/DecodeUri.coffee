test = require "noflo-test"

test.component("woute/DecodeUri").
  discuss("send some URIs").
    send.connect("in").
      send.data("in", "a%2F").
      send.data("in", "a%20b").
      send.data("in", "a%20b/c%25d").
    send.disconnect("in").
  discuss("only get back the content with a matching top-level group").
    receive.data("out", "a/").
    receive.data("out", "a b").
    receive.data("out", "a b/c%d").

export module

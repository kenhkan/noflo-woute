test = require "noflo-test"

test.component("woute/EncodeUri").
  discuss("send some to-be-encoded URIs").
    send.connect("in").
      send.data("in", "a/").
      send.data("in", "a b").
      send.data("in", "a b/c%d").
    send.disconnect("in").
  discuss("only get back the content with a matching top-level group").
    receive.data("out", "a%2F").
    receive.data("out", "a%20b").
    receive.data("out", "a%20b%2Fc%25d").

export module

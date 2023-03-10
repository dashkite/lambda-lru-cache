import { test as _test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

import { convert } from "@dashkite/bake"
import { syncInvokeLambda } from "@dashkite/dolores/lambda"

import request from "./data/template"
import * as $ from "../src"

fetch = if process.env.targets == "remote"
  (request) ->
    { Payload, StatusCode } = await syncInvokeLambda "dashkite-test-load-media", request
    if 200 <= StatusCode < 300
      JSON.parse convert to: "utf8", from: "bytes", Payload
    else
      status: 502
else
  $.handler

test = ( description, content ) ->
  _test { wait: false, description }, content

do ({ response } = {}) ->
  print await test "@dashkite/lambda-load-media", [

    await test "media", [
      await test "get", ->
        response = await fetch request
        
        assert.equal response.statusDescription, "ok"
        assert response.headers[ "Content-Type" ]?.includes "text/css"
    ]
  ]
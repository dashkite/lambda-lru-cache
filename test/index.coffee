import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { Client } from "../src/client"

do ->

  client = new Client "dashkite-development-lru-cache", "test"

  print await test "dashkite/lambda-lru-cache", [

    test "basic caching", [

      await test "clear", ->
        result = await client.clear()
        assert !result?

      await test "get", ->
        result = await client.get "foo"
        assert !result?

      await test "set", ->
        result = await client.set "foo", "bar"
        assert.equal result, "bar"

      await test "get (after set)", ->
        result = await client.get "foo"
        assert.equal result, "bar"
    ]

  ]

  process.exit if success then 0 else 1

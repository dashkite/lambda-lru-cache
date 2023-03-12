import { syncInvokeLambda } from "@dashkite/dolores/lambda"
import { convert } from "@dashkite/bake"

invoke = ( lambda, event ) ->
  { Payload, StatusCode } = await syncInvokeLambda lambda, event
  if 200 <= StatusCode < 300
    JSON.parse convert to: "utf8", from: "bytes", Payload
  else
    throw new Error "Lambda invocation failure"

class Client

  constructor: ( @lambda, @cache ) ->
  
  get: ( key ) ->
    invoke @lambda,
      name: "get"
      parameters: { @cache, key }

  set: ( key, value ) ->
    invoke @lambda,
      name: "set"
      parameters: { @cache, key, value }

  clear: ->
    invoke @lambda,
      name: "clear"
      parameters: { @cache }

export { Client }
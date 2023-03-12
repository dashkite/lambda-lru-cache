import { LRUCache } from "@dashkite/lru-cache"
import * as Queue from "@dashkite/dolores/sqs"
import * as Topic from "@dashkite/dolores/sns"
import { publish, subscribe } from "@dashkite/dolores/sns"
import { confidential } from "panda-confidential"

{ pop } = Queue
{ randomBytes, convert } = confidential()

Caches = {}

Cache =
  get: ( name ) ->
    Caches[ name ] ?= new LRUCache

Actions =
  
  get: ({ cache, key }) ->
    Cache
      .get cache
      .get key
    
  set: ({ cache, key, value }) ->
    Cache
      .get cache
      .set key, value
    value

  delete: ({ cache, key }) ->
    Cache
      .get cache
      .delete key, value
    undefined

  clear: ({ cache }) ->
    Cache
      .get cache
      .clear()
    undefined

Action =
  
  run: ({ name, parameters }) ->
    Actions[ name ].apply null, [ parameters ]

initialize = do ({ queue, address, topic, subscribed } = {}) -> ->
  
  address ?= convert from: "bytes", to: "base36",
    await randomBytes 8

  queue ?= await Queue.create address

  # TODO topic name should come from configuration
  topic ?= await Topic.create "dashkite-lru-cache"
  
  unless subscribed?
    await subscribe topic, queue
    subscribed = true

  { address, queue, topic }

handler = ( event ) ->

  performance.mark "initialize"
  { queue, address, topic } = await initialize()

  performance.mark "check messages"
  for message in ( await pop queue ) when message.from != address
    Action.run message.event

  performance.mark "run handler"
  try
    result = Action.run event
    performance.mark "publish event"
    publish topic, { from: address, event }
      .catch ( error ) ->
        console.error error.message
  catch error
    throw error
  
  performance.mark "return result"

  performance.measure "initialization", "initialize", "check messages"
  performance.measure "checking messages", "check messages", "run handler"
  performance.measure "publishing event", "publish event", "return result"
  performance.measure "overall", "initialize", "return result"

  performance
    .getEntriesByType "measure"
    .forEach ({ name, duration }) ->
      console.log name, duration

  result

export { handler }

import * as Graphene from "@dashkite/graphene-core"
import { getObject } from "@dashkite/dolores/bucket"
import { MediaType } from "@dashkite/media-type"
import configuration from "../configuration"
import { convert } from "@dashkite/bake"

makeContent = ( content, type ) ->

grapheneClient = Graphene.Client.create()

cors = ( response ) ->
  response.headers ?= {}
  Object.assign response.headers,
    "access-control-allow-credentials": [ "true" ]
    "access-control-allow-headers": [ "*" ]
    "access-control-allow-methods": [ "*" ]
    "access-control-allow-origin": [ "*" ]
    "access-control-expose-headers": [ "*" ]
    "access-control-max-age": [ "7200" ]
  response

handlers =
  get: ( request, bindings ) ->
    target = bindings.path
    domain = request.domain
    { fallback } = configuration[ domain ] ? {}

    # TODO generate these based on accept?
    # TODO use configuration to determine

    # drop the leading /
    # TODO we could simply require the / in the key by convention?
    target = target[1..]
    candidates = []

    if target == "" then candidates.push "index.html"
    else if target.endsWith "/" then candidates.push target[...-1]
    else if !( /\.\w+$/.test target )
      candidates.push "#{target}.html"
      candidates.push "#{target}/index.html"
      if fallback? && !( fallback in candidates )
        candidates.push fallback
    else
      candidates.push target
    
    if candidates.length == 0
      description: "not found"
    else
      collection = grapheneClient.collection { db: configuration.db, collection: domain }
      content = encoding = undefined
      for key in candidates
        break if content?
        type = MediaType.fromPath key
        switch MediaType.category type
          when "text", "json"
            encoding = "text"
            try
              content = await collection.get key
            catch error
              if error.message != "Requested resource not found"
                console.error "unexpected error when attempting to load media"
                console.log error
          when "binary"
            encoding = "base64"
            object = await getObject domain, key
            content = if object?
              convert from: "bytes", to: "base64", object.content
      cors if content?
        description: "ok"
        content: content
        encoding: encoding
        headers:
          "content-type": [ MediaType.format type ]
      else
        description: "not found"


export default handlers
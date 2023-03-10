import lambda from "@dashkite/sky-lambda/alb"
import description from "./api"
import handlers from "./handlers"

handler = lambda ( request ) ->
  console.log "lambda load media request headers", request.headers
  request.domain = request.headers.host[0]
  bindings = path: request.target
  handlers.media.get request, bindings

export { handler }

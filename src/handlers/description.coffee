import description from "../api"

handlers =
  get: ->
    description: "ok"
    content: description

export default handlers
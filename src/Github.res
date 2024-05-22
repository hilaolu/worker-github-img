open Prelude

type response
module Response = {
  @send external text: response => promise<string> = "text"
  @get external status: response => int = "status"
}

external fetch: (string, AnyDict.t) => promise<response> = "fetch"

let put = async (payload, filename) => {
  let url = `https://api.github.com/repos/${Env.repo}/contents/${filename}`
  let token = Env.token

  let headers = AnyDict.fromArray([
    ("Content-Type", "application/json"),
    ("Authorization", `token ${token}`),
    ("User-Agent", "Awesome-Octocat-App"),
  ])

  let body = `{"message":"","committer":{"name":"Monalisa Octocat","email":"octocat@github.com"},"content":"${payload}"}`

  let init = AnyDict.fromArray([("method", "PUT"), ("body", `${body}`), ("headers", headers)])

  let response = await fetch(url, init)

  let text = await response->Response.text
  let result = text->AnyDict.parseString

  switch result->AnyDict.get("message") {
  | None => Ok("Update success")
  | Some(s) => Error(s)
  }
}

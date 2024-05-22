type response
@val external fetch: (string, Js.Dict.t<string>) => promise<response> = "fetch"
@send external json: response => promise<'a> = "json"
@get external ok: response => bool = "ok"

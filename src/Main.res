open Belt.Result

type headers

module Request = {
  @send external get: (headers, string) => string = "get"
}

let app: Hono.t<unit> = Hono.make()

let _ = app->Hono.put("/api/:filename", async ctx => {
  let req = ctx->Hono.Context.req
  let fname = req->Hono.Request.params->Js.Dict.unsafeGet("filename")
  let payload = await req->Hono.Request.text
  let result = await payload->Github.put(fname)

  let resp = switch result {
  | Ok(s) => s
  | Error(e) => e
  }
  let response = ctx->Hono.Context.body(resp)
  response
})

let _ = app->Hono.get("/public/*", async ctx => {
  await ctx->%raw("ctx=>{return ctx.env.ASSETS.fetch(ctx.req.raw);}")
})

let _ = app->Hono.get("/", async ctx => {
  let html = `
   <!doctype html>
    <html lang="en">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Vite App</title>
    </head>

    <body>
        <div id="app">hello react</div>
        <script type="module" src="./public/Client.res.js"></script>
    </body>

    </html>
  `
  let response = ctx->Hono.Context.html(html)
  response
})

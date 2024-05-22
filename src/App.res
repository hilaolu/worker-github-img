let fetchBase64 = %raw("
(file)=>{
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result.split(',')[1]);
    reader.onerror = error => reject(error);
  });
}
")

let put = async (base64, name) => {
  let headers = Js.Dict.fromArray([("method", "PUT"), ("body", base64)])
  let base = Webapi.Dom.location->%raw("t=>{return t;}")
  (await Lib.fetch(base ++ "/" ++ name, headers))->ignore
  ()
}

@react.component
let make = () => {
  let (getState, updateState) = React.useState(() => {[]})

  let onPaste = evt => {
    evt
    ->ReactEvent.Clipboard.clipboardData
    ->%raw("t=>{return Array.from(t.items)}")
    ->Array.map(i => {
      let kind = i->Js.Dict.get("kind")
      let t = i->Js.Dict.get("type")
      let f = i->%raw("t=>{return t.getAsFile();}")

      switch (kind, t) {
      | (Some("file"), Some("image/png")) =>
        let name = Js.Date.make()->Js.Date.toISOString ++ ".png"

        let new_url = Env.base_url ++ name
        updateState(arr => {
          arr->Array.concat([new_url])
        })

        f
        ->fetchBase64
        ->Promise.then(async base64 => {
          await base64->put(name)
        })
        ->ignore

      | _ => ()
      }
    })
    ->ignore
    ()
  }

  <div onPaste>
    {
      let style = ReactDOM.Style.make(~position="fixed", ~top="10px", ~left="10px", ())
      <input style type_="text" autoFocus=true />
    }
    {getState->Array.map(url => <Box url />)->React.array}
  </div>
}

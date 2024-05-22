let copyToClipboard = text => {
  text
  ->%raw("text=>{navigator.clipboard.writeText(text).then(function() {
          console.log('Text copied to clipboard successfully!');
      }).catch(function(err) {
          console.error('Failed to copy text: ', err);
      });}")
  ->ignore
  ()
}

@react.component
let make = (~url) => {
  let (getUrl, setUrl) = React.useState(() => "")

  let rec trunk = i => {
    let _ = setTimeout(() => {
      (url ++ "?v=" ++ i->Int.toString)
      ->Lib.fetch(Js.Dict.fromArray([]))
      ->Promise.then(async response => {
        if response->Lib.ok {
          setUrl(_ => {url})
        } else {
          (i + 1)->trunk
        }
      })
      ->ignore
    }, 5000)
  }

  React.useEffect(() => {
    0->trunk
    None
  }, [])

  let style = ReactDOM.Style.make(
    ~width="400px",
    ~height="300px",
    ~textAlign="center",
    ~margin="10px 10px",
    ~display="inline-block",
    (),
  )
  <img
    style
    src=getUrl
    alt="image uploading..."
    onClick={_ => {
      url->copyToClipboard
    }}
  />
}

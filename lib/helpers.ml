module Int = Core.Int
module String = Core.String

let __nullchar = Char.unsafe_chr 0

let pad ~basis msg =
  let encoded = Encoding.encode msg in
  let length = String.length encoded in
  let remainder = Int.( % ) length basis in
  let zerofill = String.make (basis - remainder) __nullchar in
  encoded ^ zerofill


let __nonzero char = char != __nullchar

(* ignores input if it can't be base64-decoded after dropping null-padding data *)
let unpad msg =
  let filtered = String.filter ~f:__nonzero msg in
  try Encoding.decode @@ filtered with Failure _ -> msg

module Int = Core.Int
module String = Core.String
module Char = Core.Char

let __nullchar = Char.of_int_exn 0

let pad ~basis msg =
  let encoded = Encoding.encode msg in
  let length = String.length encoded in
  let remainder = Int.( % ) length basis in
  if remainder = 0 then msg else
  let zerofill = String.make (basis - remainder) __nullchar in
  encoded ^ zerofill

let __nonzero char = char != __nullchar

let unpad msg = Encoding.decode @@ String.filter ~f:__nonzero msg

let string_to_hex data = Hex.show @@ Hex.of_string data

let string_of_hex hex = Hex.to_string (`Hex hex)

let hex_of_base64 data = string_to_hex @@ Encoding.decode data

let hex_to_base64 hex = Encoding.encode @@ string_of_hex hex

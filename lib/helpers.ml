module Int = Core.Int
module String = Core.String

(*
let __nullchar = Char.unsafe_chr 0

let pad ~basis msg =
  let encoded = Encoding.encode msg in
  let length = String.length encoded in
  let remainder = Int.( % ) length basis in
  let zerofill = String.make (basis - remainder) __nullchar in
  encoded ^ zerofill
*)

let pad ~basis msg =
  let length = String.length msg in
  let remainder = Int.( % ) length basis in
  if remainder = 0 then msg else
  let padsize = basis - remainder in
  let padbyte = Char.unsafe_chr padsize in
  let padfill = String.make padsize padbyte in
  msg ^ padfill


(*
let __nonzero char = char != __nullchar
*)

(* ignores input if it can't be base64-decoded after dropping null-padding data *)
(*
let unpad msg =
  let filtered = String.filter ~f:__nonzero msg in
  try Encoding.decode @@ filtered with Failure _ -> msg
*)

let unpad msg =
  let length = String.length msg in
  let padbyte = String.get msg (length - 1) in
  let padsize = Char.code padbyte in
  if padsize > length then msg else
  let padfill = String.make padsize padbyte in
  let padding = String.sub msg ~pos:(length - padsize) ~len:padsize in
  if Hashing.mac_compare_string padfill padding
  then String.sub msg ~pos:0 ~len:(length - padsize)
  else msg


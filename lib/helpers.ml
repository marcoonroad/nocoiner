module Int = Base.Int
module String = Base.String

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
  if remainder = 0 && length != 0 then msg else
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


let __get_uint8 cstruct index =
  try Cstruct.get_uint8 cstruct index with
  | Invalid_argument _ -> 0

let cstruct_xor left right =
  let length = max (Cstruct.len left) (Cstruct.len right) in
  let result = Cstruct.create length in
  let rec __loop index =
    if index = length then () else begin
      let left_byte = __get_uint8 left index in
      let right_byte = __get_uint8 right index in
      let xored_byte = left_byte lxor right_byte in
      Cstruct.set_uint8 result index xored_byte ;
      __loop (index + 1)
    end
  in
  __loop 0 ;
  result

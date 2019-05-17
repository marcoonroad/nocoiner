module String = Core.String
module List = Core.List

let string_to_hex = Helpers.string_to_hex

let string_of_hex = Helpers.string_of_hex

let __not_missing char = char != '?'

let __const_zero _ = 0

let __digest = Hashing.hash

let __hex_of_int = function
  | 0 ->
      '0'
  | 1 ->
      '1'
  | 2 ->
      '2'
  | 3 ->
      '3'
  | 4 ->
      '4'
  | 5 ->
      '5'
  | 6 ->
      '6'
  | 7 ->
      '7'
  | 8 ->
      '8'
  | 9 ->
      '9'
  | 10 ->
      'a'
  | 11 ->
      'b'
  | 12 ->
      'c'
  | 13 ->
      'd'
  | 14 ->
      'e'
  | 15 ->
      'f'
  | _ ->
      failwith "Invalid hex number!"

let generate ?difficulty:(amount = 1) message =
  let hex_message = string_to_hex message in
  let hash = __digest message in
  let hex_length = String.length hex_message in
  let unknown = String.make amount '?' in
  let known = String.sub ~pos:0 ~len:(hex_length - amount) hex_message in
  let masked = known ^ unknown in
  (masked, hash)

let exhausted buffer =
  let __predicate node = node = 15 in
  List.for_all buffer ~f:__predicate

let __buffer_to_hex_string buffer =
  let hex_chars = List.map ~f:__hex_of_int buffer in
  String.of_char_list hex_chars

let rec __tick_step = function
  | [] ->
      []
  | 15 :: rest ->
      0 :: __tick_step rest
  | node :: rest ->
      (node + 1) :: rest

let __tick_buffer buffer =
  if exhausted buffer then raise Exceptions.ExhaustedBruteForce else __tick_step buffer

let break ~message ~hash =
  let known = String.filter ~f:__not_missing message in
  let unknown_length = String.length message - String.length known in
  let buffer = List.init ~f:__const_zero unknown_length in
  let rec __loop buffer =
    let suffix = __buffer_to_hex_string buffer in
    let hex_candidate = known ^ suffix in
    let result = __digest @@ string_of_hex hex_candidate in
    if result = hash then suffix
    else
      let next = __tick_buffer buffer in
      __loop next
  in
  string_of_hex @@ known ^ __loop buffer

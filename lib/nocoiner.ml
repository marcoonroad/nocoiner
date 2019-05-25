module Reasons = Exceptions
module String = Core.String
module List = Core.List

let __join ~on left right =
  Encoding.encode_blob left ^ on ^ Encoding.encode_blob right

let __hex_join ~on left right = left ^ on ^ right

let commit ?(difficulty = 5) message =
  if difficulty < 3 then raise Reasons.InvalidDifficulty
  else
    let key = Entropy.key () in
    let iv = Entropy.iv () in
    let fingerprint = Fingerprint.id () in
    let payload = Encoding.encode message ^ ":" ^ fingerprint in
    let cipher, tag = Encryption.encrypt ~key ~iv ~message:payload in
    let commitment = __join cipher ~on:"@" tag in
    let opening = __join key ~on:"." iv in
    let key_hex = Helpers.hex_of_base64 @@ Encoding.encode_blob key in
    let iv_hex = Helpers.hex_of_base64 @@ Encoding.encode_blob iv in
    let key_masked, key_hash = Analysis.generate ~difficulty key_hex in
    let iv_masked, iv_hash = Analysis.generate ~difficulty iv_hex in
    let key_piece = __hex_join key_masked ~on:" " key_hash in
    let iv_piece = __hex_join iv_masked ~on:" " iv_hash in
    let piece = key_piece ^ "%" ^ iv_piece in
    (commitment ^ "$" ^ piece, opening)

let __decode ~reason data =
  try Encoding.decode_as_blob data with _ -> raise reason

let __split ~reason ~on data =
  match String.split data ~on with
  | [left; right] ->
      (__decode ~reason left, __decode ~reason right)
  | _ ->
      raise reason

let reveal ~commitment:commitment' ~opening =
  let open Reasons in
  let commitment = List.nth_exn (String.split ~on:'$' commitment') 0 in
  let key, iv = __split ~reason:InvalidOpening ~on:'.' opening in
  let cipher, tag = __split ~reason:InvalidCommitment ~on:'@' commitment in
  let payload =
    Encryption.decrypt ~reason:BindingFailure ~key ~iv ~cipher ~tag
  in
  let parts = String.split ~on:':' payload in
  (* discards fingerprint at index 1 *)
  Encoding.decode @@ List.nth_exn parts 0

let break commitment' =
  let parts = String.split ~on:'$' commitment' in
  let commitment = List.nth_exn parts 0 in
  let piece_parts = String.split ~on:'%' @@ List.nth_exn parts 1 in
  let key_pieces = String.split ~on:' ' @@ List.nth_exn piece_parts 0 in
  let iv_pieces = String.split ~on:' ' @@ List.nth_exn piece_parts 1 in
  let key_masked = List.nth_exn key_pieces 0 in
  let key_hash = List.nth_exn key_pieces 1 in
  let iv_masked = List.nth_exn iv_pieces 0 in
  let iv_hash = List.nth_exn iv_pieces 1 in
  let key_hex = Analysis.break ~message:key_masked ~hash:key_hash in
  let iv_hex = Analysis.break ~message:iv_masked ~hash:iv_hash in
  let key = Helpers.hex_to_base64 key_hex in
  let iv = Helpers.hex_to_base64 iv_hex in
  let opening = key ^ "." ^ iv in
  reveal ~commitment ~opening

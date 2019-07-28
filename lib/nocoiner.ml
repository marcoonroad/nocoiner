module Reasons = Exceptions
module String = Core.String
module List = Core.List

let xor = Nocrypto.Uncommon.Cs.xor

let __join ~on left right =
  Encoding.encode_blob left ^ on ^ Encoding.encode_blob right

let __kdf ~key ~iv =
  let payload = Hardening.kdf ~size:64l ~salt:iv key in
  let key', rest = Cstruct.split payload 32 in
  let iv1, iv2 = Cstruct.split rest 16 in
  (key', xor iv1 iv2)

let commit message =
  let key' = Entropy.key () in
  let iv' = Entropy.iv () in
  let fingerprint = Fingerprint.id () in
  let key, iv = __kdf ~key:key' ~iv:iv' in
  let payload = Encoding.encode message ^ ":" ^ fingerprint in
  let cipher, tag = Encryption.encrypt ~key ~iv ~message:payload in
  let commitment = __join cipher ~on:"@" tag in
  let opening = __join key ~on:"." iv in
  (commitment, opening)

let __decode ~reason data =
  try Encoding.decode_as_blob data with _ -> raise reason

let __split ~reason ~on data =
  match String.split data ~on with
  | [left; right] ->
      (__decode ~reason left, __decode ~reason right)
  | _ ->
      raise reason

let reveal ~commitment ~opening =
  let open Reasons in
  let key, iv = __split ~reason:InvalidOpening ~on:'.' opening in
  let cipher, tag = __split ~reason:InvalidCommitment ~on:'@' commitment in
  let payload = Encryption.decrypt ~reason:BindingFailure ~key ~iv ~cipher ~tag in
  let parts = String.split ~on:':' payload in
  Encoding.decode @@ List.nth_exn parts 0 (* discards fingerprint at index 1 *)

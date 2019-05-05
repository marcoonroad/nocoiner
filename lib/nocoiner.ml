module Reasons = Exceptions
module String = Core.String
module List = Core.List

let __join ~on left right =
  Encoding.encode_blob left ^ on ^ Encoding.encode_blob right

let commit message =
  let key = Entropy.key () in
  let iv = Entropy.iv () in
  let cipher, tag = Encryption.encrypt ~key ~iv ~message in
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
  Encryption.decrypt ~reason:BindingFailure ~key ~iv ~cipher ~tag

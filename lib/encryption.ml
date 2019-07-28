module String = Core.String
module AES = Nocrypto.Cipher_block.AES.CBC

let hash data =
  Cstruct.of_hex @@ Hashing.hash @@ Cstruct.to_string data

let mac ~key data =
  let key', data' = Cstruct.to_string key, Cstruct.to_string data in
  Cstruct.of_hex @@ Hashing.mac ~key:key' data'

let encrypt ~key:key' ~iv ~message:msg =
  let key = AES.of_secret key' in
  let plaintext = Helpers.pad ~basis:16 msg in
  let ciphertext = AES.encrypt ~iv ~key @@ Cstruct.of_string plaintext in
  let secret = hash key' in
  let tag = mac ~key:secret ciphertext in
  (ciphertext, tag)

let decrypt ~reason ~key:key' ~iv ~cipher ~tag =
  let secret = hash key' in
  let tag' = mac ~key:secret cipher in
  if Cstruct.equal tag tag' then
    let key = AES.of_secret key' in
    let plaintext = AES.decrypt ~iv ~key cipher in
    Helpers.unpad @@ Cstruct.to_string plaintext
  else raise reason

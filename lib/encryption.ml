module String = Core.String
module AES = Nocrypto.Cipher_block.AES.CBC

let _MIN_BITS = Entropy.min_bits (32 * 8)

let _MAX_BITS = Entropy.max_bits (32 * 8)

let __kdf key =
  let aes_salt = _MIN_BITS in
  let mac_salt = _MAX_BITS in
  let aes_key = Hardening.kdf ~size:32l ~salt:aes_salt key in
  let mac_key = Hardening.kdf ~size:32l ~salt:mac_salt key in
  (aes_key, mac_key)


let hash data = Cstruct.of_string @@ Hashing.raw_hash @@ Cstruct.to_string data

let mac ~key data =
  let key', data' = (Cstruct.to_string key, Cstruct.to_string data) in
  Cstruct.of_string @@ Hashing.raw_mac ~key:key' data'


let mac_compare_equal left right =
  let key = Entropy.key () in
  let left' = mac left ~key in
  let right' = mac right ~key in
  Eqaf_cstruct.equal left' right'


let encrypt ~key ~iv ~metadata ~message:msg =
  let aes_key, mac_key = __kdf key in
  let aes_key' = AES.of_secret aes_key in
  let plaintext = Helpers.pad ~basis:16 @@ Cstruct.to_string msg in
  let ciphertext =
    AES.encrypt ~iv ~key:aes_key' @@ Cstruct.of_string plaintext
  in
  let secret = hash mac_key in
  let payload = Cstruct.append metadata @@ Cstruct.append iv ciphertext in
  let tag = mac ~key:secret payload in
  (ciphertext, tag)


exception DecryptedPlaintext of Cstruct.t

let decrypt ~reason ~key ~iv ~metadata ~cipher ~tag =
  let aes_key, mac_key = __kdf key in
  let secret = hash mac_key in
  let payload = Cstruct.append metadata @@ Cstruct.append iv cipher in
  let tag' = mac ~key:secret payload in
  (* we decypher before the tag verification to avoid
     exploitable side-channels vulnerabilities such as
     timing attacks. we also check the tags in linear
     time regarding the tag size in bytes *)
  let aes_key' = AES.of_secret aes_key in
  let plaintext = AES.decrypt ~iv ~key:aes_key' cipher in
  let decrypted =
    Cstruct.of_string @@ Helpers.unpad @@ Cstruct.to_string plaintext
  in
  (* forces both bound and unbound flows to pass through the exception triggering
     pipeline. this is just to approximate both execution timings to reduce the
     vector attacks for side-channel attacks *)
  try
    if mac_compare_equal tag tag'
    then raise (DecryptedPlaintext decrypted)
    else raise reason
  with
  | DecryptedPlaintext result ->
      result

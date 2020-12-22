module SHA256 = Mirage_crypto.Hash.SHA256

let raw_hash data =
  Cstruct.to_string @@ SHA256.digest @@ Cstruct.of_string data


let raw_mac ~key data =
  let key' = Cstruct.of_string key in
  let data' = Cstruct.of_string data in
  Cstruct.to_string @@ SHA256.hmac ~key:key' data'


let mac_compare_string left right =
  let key = Cstruct.to_string (Entropy.key ()) in
  let left' = raw_mac ~key left in
  let right' = raw_mac ~key right in
  Eqaf.equal left' right'


let mac_compare_cstruct left right =
  let left' = Cstruct.to_string left in
  let right' = Cstruct.to_string right in
  mac_compare_string left' right'


module Blake2B = Digestif.BLAKE2B

let raw_hash data = Blake2B.to_raw_string @@ Blake2B.digest_string data

let raw_mac ~key data =
  Blake2B.to_raw_string @@ Blake2B.Keyed.mac_string ~key data


let mac_compare_string left right =
  let key = Cstruct.to_string (Entropy.key ()) in
  let left' = raw_mac ~key left in
  let right' = raw_mac ~key right in
  Eqaf.equal left' right'


let mac_compare_cstruct left right =
  let left' = Cstruct.to_string left in
  let right' = Cstruct.to_string right in
  mac_compare_string left' right'


module Blake2B = Digestif.BLAKE2B

let raw_hash data = Blake2B.to_raw_string @@ Blake2B.digest_string data

let raw_mac ~key data =
  Blake2B.to_raw_string @@ Blake2B.Keyed.mac_string ~key data

module Blake2B = Digestif.BLAKE2B

let hash data = Blake2B.to_hex @@ Blake2B.digest_string data

let hash_blob blob = hash @@ Cstruct.to_string blob

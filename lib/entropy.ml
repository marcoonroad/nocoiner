module RngZ = Nocrypto.Rng.Z
module NumZ = Nocrypto.Numeric.Z

let key () = NumZ.to_cstruct_be @@ RngZ.gen_bits 256

let iv () = NumZ.to_cstruct_be @@ RngZ.gen_bits 128

let _ = Nocrypto_entropy_unix.initialize ()

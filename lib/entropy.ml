let key () = Mirage_crypto_rng.generate 32

let iv () = Mirage_crypto_rng.generate 16

let _ = Mirage_crypto_rng_unix.initialize ()

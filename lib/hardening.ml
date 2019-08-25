open Constants

let kdf ~size ~salt password =
  Scrypt_kdf.scrypt_kdf ~password ~salt ~dk_len:size ~r:8 ~p:_KDF_WORKERS ~n:_KDF_COST

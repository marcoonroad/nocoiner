let hash data = Cstruct.of_hex @@ Hashing.hash data

let id ( ) =
  let timestamp = hash @@ string_of_float @@ Unix.gettimeofday ( ) in
  let pid = hash @@ string_of_int @@ Unix.getpid ( ) in
  let hostname = hash @@ Unix.gethostname ( ) in
  let cwd = hash @@ Unix.getcwd ( ) in
  let context = Cstruct.to_string @@ Cstruct.concat [
    timestamp; pid; hostname; cwd
  ] in
  Encoding.encode @@ Hashing.raw_hash context

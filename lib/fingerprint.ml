module List = Core.List

let hash data = Cstruct.of_string @@ Hashing.raw_hash data

let xor = Nocrypto.Uncommon.Cs.xor

let id () =
  let timestamp = hash @@ string_of_float @@ Unix.gettimeofday () in
  let pid = hash @@ string_of_int @@ Unix.getpid () in
  let hostname = hash @@ Unix.gethostname () in
  let cwd = hash @@ Unix.getcwd () in
  let context =
    timestamp |> xor pid |> xor hostname |> xor cwd |> Cstruct.to_string
  in
  Encoding.encode @@ Hashing.raw_hash context

let encode data = Base64.encode_exn data

let decode data = Base64.decode_exn data

let encode_blob blob = encode @@ Cstruct.to_string blob

let decode_as_blob data = Cstruct.of_string @@ decode data

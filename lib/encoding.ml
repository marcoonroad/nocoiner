module Option = Core.Option
module Base64 = Nocrypto.Base64

let encode_blob cstruct = Cstruct.to_string @@ Base64.encode cstruct

let encode message = encode_blob @@ Cstruct.of_string message

let decode_as_blob encoded =
  let nullable = Base64.decode @@ Cstruct.of_string encoded in
  Option.value_exn nullable

let decode encoded = Cstruct.to_string @@ decode_as_blob encoded

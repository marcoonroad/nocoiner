module Sys = Core.Sys
module Option = Core.Option
module Int = Core.Int

let get variable default =
  let optional = Sys.getenv variable in
  Option.value optional ~default


let _KDF_COST = get "NOCOINER_KDF_COST" "8192" |> Int.of_string

let _KDF_WORKERS = get "NOCOINER_KDF_WORKERS" "2" |> Int.of_string

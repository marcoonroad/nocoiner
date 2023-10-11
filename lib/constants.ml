(* module Sys = Base.Sys *)
module Option = Base.Option
module Int = Base.Int

let get variable default =
  try
    let value = Sys.getenv variable in
    if value = "" then default else value
  with _ -> default


let _KDF_COST = get "NOCOINER_KDF_COST" "8192" |> Int.of_string

let _KDF_WORKERS = get "NOCOINER_KDF_WORKERS" "2" |> Int.of_string

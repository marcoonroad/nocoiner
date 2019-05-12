let cant_overwrite file = failwith ("Can't overwrite " ^ file ^ "!")

let write_to data file =
  let handler = open_out file in
  output_string handler data ; flush handler ; close_out handler

let read_line handler =
  try Some (input_line handler) with End_of_file -> None

let rec read_loop buffer handler =
  match read_line handler with
  | None ->
      buffer
  | Some line ->
      read_loop (buffer ^ "\n" ^ line) handler

let read_some handler =
  match read_line handler with None -> "" | Some line -> line

let read_all handler =
  let first = read_some handler in
  read_loop first handler

let read_from file =
  let handler = open_in file in
  let lines = read_all handler in
  close_in handler ; lines

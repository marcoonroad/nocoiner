val raw_hash : string -> string

val raw_mac : key:string -> string -> string

val mac_compare_cstruct : Cstruct.t -> Cstruct.t -> bool

val mac_compare_string : string -> string -> bool


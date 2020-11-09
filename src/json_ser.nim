import tables, json_serialization

let tbl: Table[int, string] = [(1, "one")].toTable
let encoded = Json.encode(tbl)

debugEcho("encoded: ", encoded)

let decoded = Json.decode(encoded, Table[int, string])
import tables, json_serialization, json_serialization/std/tables as json_tables, strutils
type
  MyObj = object
    author: string
    price: int

let
  one = MyObj(author: "one", price: 1)
  two = MyObj(author: "two", price: 2)
  tbl: Table[int, MyObj] = [
    (1, one),
    (2, two)
  ].toTable
  encoded = Json.encode(tbl)

debugEcho("encoded: ", encoded)

let decoded = Json.decode(encoded, Table[int, MyObj])
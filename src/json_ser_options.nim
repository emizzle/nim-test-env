import
  options

import
  json_serialization, json_serialization/std/options as json_options

type
  MyChild = object
    author {.serializedFieldName("etherscan-link").}: Option[string]
    price: int
  MyParent = object
    name: string
    child: MyChild

let
  one = MyParent(child: MyChild(author: some("one"), price: 1), name: "test1")
  two = MyParent(child: MyChild(author: none(string), price: 2), name: "test2")

var encoded = Json.encode(one)
debugEcho ">>> encoded (one):", encoded
debugEcho ">>> decoded (one):", $Json.decode(encoded, MyParent)
assert Json.decode(encoded, MyParent) == one
encoded = Json.encode(two)
debugEcho ">>> encoded (two):", encoded
debugEcho ">>> decoded (one):", $Json.decode(encoded, MyParent)
assert Json.decode(encoded, MyParent) == two

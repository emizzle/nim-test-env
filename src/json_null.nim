import json_serialization

type
  RpcResponse* = ref object
    jsonrpc*: string
    result*: string
    id*: int

let responseStr = "{\"jsonrpc\":\"2.0\",\"id\":0,\"result\":null}"
let response = Json.decode(responseStr, RpcResponse) # <=== Fails here with a SIGSEGV: Illegal storage access
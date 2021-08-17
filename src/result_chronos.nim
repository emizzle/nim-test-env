import # vendor modules
  chronos, stew/results

type
  Asset* = object
    name*: string

  OpenSeaError* = enum
    FetchError    = "opensea: error fetching assets from opensea"

  OpenSeaResult*[T] = Result[T, OpenSeaError]

proc queryAssets(): Future[OpenSeaResult[seq[Asset]]] {.async.} =
  return ok(@[Asset(name: "asset1")])

# This compiles and runs successfully
# proc getAssets*(limit: int): Future[OpenSeaResult[seq[Asset]]] {.async.} =
#   let assets = await queryAssets()
#   if assets.isErr: return err assets.error
#   return ok assets.get

# This does not compile!
# Error: type mismatch: got <OpenSeaResult[seq[Asset]]> but expected 'FutureBase = ref FutureBase:ObjectType'
proc getAssets*(limit: int): Future[OpenSeaResult[seq[Asset]]] {.async.} =
  let assets = ?(await queryAssets())
  return ok assets

let assets = waitFor getAssets(50)
assert assets.isOk
assert assets.get.len == 1
assert assets.get[0].name == "asset1"


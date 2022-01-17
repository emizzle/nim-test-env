import
  std/[sequtils, sugar]

import chronos
import libp2p
import stew/results except `?`

# common module
type

  ErrorInfo = object of RootObj
    info: string

  CodexError = object of CatchableError

template `?`*[T, E](self: Future[Result[T, E]]): auto =
  # co-authored by @michaelsbradleyjr
  assert declared(chronosInternalRetFuture)
  let v = (self)
  var rv = await v
  if rv.isErr:
    when typeof(result) is typeof(rv):
      chronosInternalRetFuture.complete(rv)
    else:
      when E is void:
        chronosInternalRetFuture.complete(err(typeof(result)))
      else:
        chronosInternalRetFuture.complete(err(typeof(result), rv.error))
    return chronosInternalRetFuture
  when not(T is void):
    rv.get

template `?`*[T, E](self: Result[T, E]): auto =
  let v = (self)
  when declared(chronosInternalRetFuture):
    let av = proc(): Future[Result[T, E]] {.async.} = return v
    ? av()
  else:
    results.`?` v

proc mapErrTo*[T, E1, E2](r: Result[T, E1], v: E2):
  Result[T, E2] =

  mixin toException
  var ve = v

  return r.mapErr(
    proc (e: E1): E2 =
      when e is E2:
        return ve
      elif compiles(e.toException):
        ve.parent = e.toException
      elif e is enum:
        ve.parent = newException(CodexError, $e)
      elif e is ref CatchableError:
        ve.parent = e
      ve
  )

proc mapErrTo*[T, E1, E2](r: Future[Result[T, E1]], v: E2):
  Future[Result[T, E2]] {.async.} =

  return (await r).mapErrTo(v)

# chunker module
type
  Chunker = ref object
    chunkSize*: int64

  ChunkerErrorType = enum
    InvalidChunkSize = "couldn't fill buffer because chunks size is invalid"

  # ChunkerError = object of CodexError[ChunkerErrorType]
  ChunkerError = object of CodexError

  ChunkerResult[T] = Result[T, ref ChunkerError]

const
  DefaultChunkSize*: int64 = 1024 * 256

func new*(T: type Chunker, chunkSize = DefaultChunkSize): T =
  var chunker = Chunker(chunkSize: chunkSize)
  return chunker

proc getBytes*(c: Chunker): Future[ChunkerResult[seq[byte]]] {.async.} =
  var buff = newSeq[byte](c.chunkSize) # abbrev for illustration

  # we do stuff to fill the buffer...

  # and then encounter an error
  if c.chunkSize == 0:
    # this isn't going to happen, but needed a way to make it fail in the tests
    return err newException(ChunkerError, $InvalidChunkSize)

  return ok buff

# node module
type
  NodeRef* = ref object

  NodeErrorType = enum
    StoreInvalidCid   = "couldn't create cid from chunk data"
    StoreInvalidChunk = "couldn't get chunk bytes due to invalid chunk size"

  NodeError = object of CodexError

  NodeResult[T] = Result[T, ref NodeError]

proc store*(node: NodeRef, chunkSize: int64): Future[NodeResult[Cid]] {.async.} =

  let
    chunker = Chunker.new(chunkSize) # abbreviated for illustration
    chunk = ? chunker
                .getBytes()
                .mapErrTo(newException(NodeError, $StoreInvalidChunk))

  let cid = ? Cid.init(
                CIDv0,
                multiCodec("dag-pb"),
                MultiHash.digest("sha2-256", chunk).get())
              .mapErrTo(newException(NodeError, $StoreInvalidCid))

  return ok cid

proc new*(
  T: type NodeRef): T =
  T()

# tests
let
  node =  NodeRef.new()

let res = waitFor node.store(0) # set an invalid chunk size and expect an error
assert res.isErr
assert res.error is ref NodeError
assert not res.error.parent.isNil
assert res.error.parent is ref Exception
assert res.error.parent.name == "ChunkerError"
assert res.error.parent.msg == $InvalidChunkSize
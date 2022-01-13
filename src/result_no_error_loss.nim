import
  libp2p,
  stew/results

# common module
type

  ErrorInfo = object of RootObj
    info: string

  CidErrorInfo = object of ErrorInfo
    desc: string

  CodexError = object of RootObj
    parent: ErrorInfo

func toErrorInfo(v: CidError): CidErrorInfo =
  result.desc = $v

proc mapErrTo*[T, E1, E2](r: Result[T, E1], v: E2):
  Result[T, E2] =

  mixin toErrorInfo
  var ve = v

  return r.mapErr(
    proc (e: E1): E2 =
      when E2 is CodexError:
        when e is enum:
          ve.parent.info = $e
        elif e is CodexError:
          ve.parent.info = $e.kind
        else:
          ve.parent = e.toErrorInfo
      ve
  )




# chunker module
type
  Chunker = ref object
    chunkSize*: int64

  ChunkerErrorType = enum
    InvalidChunkSize = "couldn't fill buffer because chunks size is invalid"

  ChunkerError = object of CodexError
    kind: ChunkerErrorType

  ChunkerResult[T] = Result[T, ChunkerError]

const
  DefaultChunkSize*: int64 = 1024 * 256

func new*(T: type Chunker, chunkSize = DefaultChunkSize): T =
  var chunker = Chunker(chunkSize: chunkSize)
  return chunker

proc getBytes*(c: Chunker): ChunkerResult[seq[byte]] =
  var buff = newSeq[byte](c.chunkSize) # abbrev for illustration

  # we do stuff to fill the buffer...

  # and then encounter an error
  if c.chunkSize == 0:
    # this isn't going to happen, but needed a way to make it fail in the tests
    return err ChunkerError(kind: InvalidChunkSize)

  return ok buff

# proc getBytes*(c: Chunker): Future[seq[byte]] {.async.} =
#   ## returns a chunk of bytes from
#   ## the instantiated chunker
#   ##

#   var buff = newSeq[byte](c.chunkSize)
#   let read = await c.reader(cast[ChunkBuffer](addr buff[0]), buff.len)

#   if read <= 0:
#     return @[]

#   if not c.pad and buff.len > read:
#     buff.setLen(read)

#   return buff






# node module
type
  NodeRef* = ref object

  NodeErrorType = enum
    StoreInvalidCid   = "couldn't create cid from chunk data"
    StoreInvalidChunk = "couldn't get chunk bytes due to invalid chunk size"

  NodeError = object of CodexError
    kind: NodeErrorType

  NodeResult[T] = Result[T, NodeError]

proc store*(node: NodeRef, chunkSize: int64): NodeResult[Cid] =

  let
    chunker = Chunker.new(chunkSize) # abbreviated for illustration
    chunk = ? chunker.getBytes().mapErrTo(NodeError(kind: StoreInvalidChunk)) # TODO: make this async!

    cid = ? Cid.init(
              CIDv0,
              multiCodec("dag-pb"),
              MultiHash.digest("sha2-256", chunk).get())
            .mapErrTo(NodeError(kind: StoreInvalidCid)) #NodeError(kind: StoreInvalidCid))
  return ok cid

proc new*(
  T: type NodeRef): T =
  T()








# tests
let
  node =  NodeRef.new()

let res = node.store(0) # set an invalid chunk size and expect an error
assert res.isErr
assert res.error is CodexError
assert res.error.parent != ErrorInfo()

echo repr res.error

assert res.error == NodeError(
                      kind: NodeErrorType.StoreInvalidChunk,
                      parent: ErrorInfo(info: $ ChunkerErrorType.InvalidChunkSize))
import
  chronos,
  stew/results

template `awaitr`*[T, E](self: Future[Result[T, E]]): auto =
  # can only be executed within the context of a nim-chronos async closure
  assert declared(chronosInternalRetFuture)

  let v = (self)
  var rv = await v
  if not rv.isOk:
    when typeof(result) is typeof(rv):
      chronosInternalRetFuture.complete(rv)
    else:
      chronosInternalRetFuture.complete(err(typeof result, rv.error))
    return chronosInternalRetFuture

  when not(T is void):
    rv.get

proc mapErrTo*[T, E1, E2](r: Future[Result[T, E1]], v: E2):
  Future[Result[T, E2]] {.async, raises: [Defect].} =

  return (await r).mapErr(proc (e: E1): E2 = v)

# type
#   FnResult[T] = Result[T, string]
#   CallerResult[T] = Result[T, string]
#   CallerMapErrResult[T] = Result[T, int]

proc fn*(retErr: bool): Future[Result[int, string]] {.async.} =
  if retErr:
    return err "there was an error"
  else:
    return ok 1

proc caller*(retErr: bool): Future[Result[int, string]] {.async.} =
  let r = awaitr fn(retErr)
  return ok r

proc callerMapErr*(retErr: bool): Future[Result[string, int]] {.async.} =
  let r = awaitr (fn(retErr).mapErrTo(0))
  return ok $r

var res = waitFor caller(true)
assert res.isErr
assert res.error == "there was an error"

res = waitFor caller(false)
assert res.isOk
assert res.get == 1

var resMapErr = waitFor callerMapErr(true)
assert resMapErr.isErr
assert resMapErr.error == 0

resMapErr = waitFor callerMapErr(false)
assert resMapErr.isOk
assert resMapErr.get == "1"
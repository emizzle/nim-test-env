import chronos

let
  (rfd, wfd) = createAsyncPipe()
  transp = fromPipe(wfd)

discard waitFor transp.write("hi")
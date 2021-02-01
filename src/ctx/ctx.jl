"Poor (fast) man's Cassette"
module Ctx

using Base.Threads

export ctxapl

const GLOBALCTX = []

function setctx!(key, value; id = Threads.threadid())
  GLOBALCTX[id][key] = value
end

"Get the context (for this thread"
function getctx(key; id = Threads.threadid())
  GLOBALCTX[id][key]
end

"""
Contextual function application

`ctxapl(ctx, f, x1, x2, ...)`

evaluates `f(x1, x2, ...) in some context `ctx`.

This serves a similar purpose to `overdub` in the Cassette module,
except that sometimes we can use more efficient methods
"""
function ctxapl end

end
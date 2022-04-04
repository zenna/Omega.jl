module Util

# import MacroTools: postwalk, prewalk
using MLStyle
using ..AExpressions

export postwalkstate,
       postwalkpos,
       parentwalk

"""
Wraps MacroToolls.postwalk:

postwalk(f, expr)
Applies `f` to each node in the given expression tree, returning the result.
`f` sees expressions *after* they have been transformed by the walk. See also
`prewalk`.
"""

walk(x, inner, outer, mapf) = outer(x)
walk(x::AExpr, inner, outer, mapf = map) =
  outer(AExpr(x.head, mapf(inner, x.args)...))

postwalk(f, x, mapf = map) = walk(x, x -> postwalk(f, x, mapf), f, mapf)

@inline mapenumerate(f, xs) = map(f, enumerate(xs))
@inline mapid(f, xs) = map(f, 1:length(xs), xs)

# ## With state

"""
Postwalk with state.

`postwalkstate(x::Expr, f, state, statef, mapf = map)`

postwalk(f, expr)
Applies `f(expr, state)` to each node in the given expression tree, returning the result.
`f` sees expressions *after* they have been transformed by the walk.
`state` seen by each node is inductively defined:
  `state` for `x` is `state`
  `state` for each child of is `stataf(state, parent, i)` where
    `parent` is the parent of 
    `i` is position of child in `parent`
```
s0 = Int[]
statef(state, arg, i) = @show [i; state]
expr = AExpr(:(let x = 4, y = 3
  x + y
end))
f(expr, state) = expr
postwalkstate(expr, f, s0, statef)
```
"""
postwalkstate(f, x::AExpr, state, statef) = 
  let g(i, x_) = postwalkstate(f, x_,  statef(state, x, i), statef)
    # @show x.args
    f(AExpr(x.head, mapid(g, x.args)...), state)
  end

postwalkstate(f, x, state, statef) = f(x, state)

idappend(state, arg, i) = [state; i]
postwalkpos(f, x, p0 = Int[]) = postwalkstate(f, x, p0, idappend)

"""
Walk from `subex` upwards through parents

```
prog = au\"\"\"
(program
  (= x 3)
  (= y (fn (a b c) (+ a b c))))\"\"\"

subex = subexpr(prog, [2, 2, 3])
f(x) = println(x.head)
parentwalk(f, prog)
```
"""
function parentwalk(f, subex)
  while !isroot(subex)
    subex = parent(subex)
    f(subex)
  end
end


end
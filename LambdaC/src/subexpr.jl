"LambdaC SubExpressions"
module SubExpressions

using ..AExpressions
using ..Util
import Base.Iterators

export SubExpr,
       subexpr,
       resolve,
       update,
       subexprdfs,
       subexprs,
       pos,
       parent,
       isroot,
       parentwalk,
       depth,
       siblings,
       ancestors,
       youngersiblings,
       isyoungersibling,
       descendents

       
"Subexpression of `parent::AE` indicated by pointer `p::P`"
struct SubExpr{AExpr, P}
  aex::AExpr
  pointer::P
end

function Base.getproperty(subex::SubExpr, v::Symbol)
  if v == :head
    resolve(subex).head
  elseif v == :args
    resolve(subex).args
  else
    getfield(subex, v)
  end
end

Base.:(==)(x::SubExpr, y::SubExpr) = (x.aex == y.aex) && (x.pointer == y.pointer)

subexpr(aexpr, id) = SubExpr(aexpr, id)
subexpr(aexpr, id::Integer) = SubExpr(aexpr, [id])
subexpr(::SubExpr) = error("Cannot take subexpression of subexpression, yet")

"Remove last element of `xs`"
pop(xs::AbstractVector) = xs[1:end-1]

"remove last `n` memebers of xs"
pop(xs, n) = xs[1:end-n]

"`subex` is is the `pos(subex)`th child of `parent(subex)`"
pos(subex::SubExpr) = subex.pointer[end]

"Is `subex` the root expression?"
isroot(subex::SubExpr) = isempty(subex.pointer)

depth(subex::SubExpr) = length(subex.pointer)

"Head of AExpr pointed to by `subex`"
AExpressions.head(subex::SubExpr) =
  AExpressions.head(resolve(subex))

"Returns subexpressions that are children"
function AExpressions.args(subexpr::SubExpr)
  q = g(resolve(subexpr))
  (SubExpr(subexpr.aex, append(subexpr.pointer, i)) for i = 1:length(q))
end
g(aex::AExpr) = aex.args
g(x) = []
append(xs::AbstractVector, x) = [xs; x]

AExpressions.args(subexpr::SubExpr, i) = 
  SubExpr(subexpr.aex, append(subexpr.pointer, i))

"Resolve Value pointed to by `subexpr`"
function resolve(subexpr::SubExpr)
  ex = subexpr.aex
  for id in subexpr.pointer
    ex = arg(ex, id)
  end
  ex
end

# ## Traversal

"""Update subexpr.aex such that `subexpr` is `newexpr`

```
prog = au\"\"\"
(program
  (: x Int)
  (= x 3)
  (= y (initnext (+ 1 2) (/ 3 this)))
  (= z (f 1 2))
)\"\"\"
.push(w)

subexpr_ = subexpr(prog, [2])

prog2 = au\"\"\"(= x 4000)\"\"\"
update(subexpr_, prog2)
```
\"\"\"
```
"""
function update(subexpr::SubExpr, newexpr)
  function subchild(expr, pos)
    # @show pos, subexpr.pointer
    # @show pos == subexpr.pointer
    pos == subexpr.pointer ? newexpr : expr
  end
  postwalkpos(subchild, subexpr.aex)
end

"Depth first search of subexpressions"
function subexprdfs(subexpr::SubExpr)
  # What's wrong with this
  # 1. we're not using the result 
  # 2. push pop needs better data structure
  # 3. not iterator friedly
  # 4. will be ha       parentwalk

  s = SubExpr[]
  res = SubExpr[]
  push!(s, subexpr)
  discovered = Set{SubExpr}()
  while !isempty(s)
    v = pop!(s)
    push!(res, v)
    if v ∉ discovered
      push!(discovered, v)
      for subexpr in args(v)
        push!(s, subexpr)
      end
    end
  end
  res
end

"""
`parentwalk(f, subex, s = f(subex))`
Walk from `subex` upwards through parents

```
prog = au\"\"\"
(program
  (= x 3)
  (= y (fn (a b c) (+ a b c))))\"\"\"

subex = subexpr(prog, [2, 2, 3])
f(x) = println(x.head)
parentwalk(subex, prog)
```
"""
function parentwalk(f, subex, s)
  while !isroot(subex)
    subex = Base.aex(subex)
    s = f(subex, s)
  end
  s
end

# Use DFS by default
subexprs(x) = subexprdfs(x)

# Base.iterate(S::SubExpr, state)

subexprdfs(aexpr::AExpr) =
  subexprdfs(subexpr(aexpr, Int[]))

# Relations

"`parent(subex::SubExpr)` Parent SubExpr of `subex`"
Base.parent(subex::SubExpr) = SubExpr(subex.aex, pop(subex.pointer))

"`i`th order parent.  `i==1` is parent, `i == 2` is grandparent, etc"
Base.parent(subex::SubExpr, i) = SubExpr(subex.aex, pop(subex.pointer, i))

"Descendents of `subex`"
descendents(subex::SubExpr) = subexprdfs(subex)

"Ancestors of `subexpr`"
ancestors(subex::SubExpr) =
  (SubExpr(subex.aex, pop(subex.pointer, i)) for i = 1:depth(subex))
siblings(subex::SubExpr) = args(parent(subex))

"Siblings that have an position greater than subex"
youngersiblings(subex::SubExpr) =
  Iterators.filter(sib -> pos(sib) > pos(subex), siblings(subex))

"is `subexa` a youngersibling of `subexb`"
isyoungersibling(subexa::SubExpr, subexb::SubExpr) = 
  subexa ∈ youngersiblings(subexb)

Base.show(io::IO, subexpr::SubExpr) =
  print(io, "Subexpression @ ", subexpr.pointer, ":\n", subexpr.aex, "\n=>\n", resolve(subexpr), "\n")

  
  

end
## A minimal symbolic probabilistic programming language
using Distributions
using Spec

"Random Variable `Ω -> T`"
struct RandVar{T}
  expr::Expr
  ωids::Set{Int}
end

"Random Variable `name::Ω -> T` where `name(ω) = body`"
struct RandVar{T}
  name::Symbol
  body::Expr
  ωids::Set{Int}
  function name()
    @pre true
  end
end

Base.Expr(x::RandVar) = :($name(ω::Omega) = $body)

"Sample Space"
struct Omega
  d::Dict{Int, Float64}
end
Omega() = Omega(Dict())
ωids(ω::Omega) = Set(keys(ω))

function Base.getindex(ω::Omega, i)
  ω.d[i] = get(ω.d, i, rand())
end

function update(ω::Omega, i::Integer, val::Float64)
  ω2 = deepcopy(ω)
  ω2[i] = val
  ω2
end

function update(ω::Omega, is::Vector{Int}, vals::Vector{Float64})
  foreach(is, vals) do i, val
    ω = update(ω, i, val)
  end
  ω
end

"Merge `ω1` and `ω2`, values in `ω2` take precedence"
function Base.merge(ω1::Omega, ω2::Omega)
  for (key, val) in ω2.d
    ω1 = update(ω1, key, val)
  end
  ω1
end

## Compilation
## ===========
"Compile `r` to julia function"
compile(r::RandVar) = eval(r.expr)

"`x(ω)`"
function (x::RandVar{T})(ω::Omega)::T where T
  Base.invokelatest(compile(x), ω)
end

"Sample from `x`"
Base.rand(x::RandVar) = x(Omega())

global ωcounter = 1
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

ωids(x) = Set{Int}()
ωids(x::RandVar) = x.ωids

ok(x::Real) = x
ok(x::RandVar) = :($(x.expr)(ω))

## Primitive Distributions
## =======================
"`uniform(a, b)`"
function uniform(a, b, ωid=ωnew())
  allωids = union(Set(ωid), ωids(a), ωids(b))
  e = :(ω -> ω[$ωid] * ($b - $a) + $a)
  RandVar{Real}(e, allωids)
end

function uniform(a, b, ωid=ωnew())
  ω[i]
  allωids = union(Set(ωid), ωids(a), ωids(b))
  e = :(ω -> ω[$ωid] * ($b - $a) + $a)
  RandVar{Real}(e, allωids)
end

"Quantile function for normal"
function invcdf(p)
  n = Normal(0, 1)
  quantile(n, p)
end

"normal with mean μ and variance σ"
function normal(μ, σ, ωid=ωnew())
  allωids = union(Set(ωid), ωids(μ), ωids(σ))
  e = :(ω -> invcdf(ω[$ωid]) * $(ok(σ)) + $(ok(μ)))
  RandVar{Real}(e, allωids)
end

## Lifted Functions
## ================
function Base.in(x::RandVar, ab::Vector)
  a, b = ab
  allωids = union(x.ωids, ωids(a), ωids(b))
  e = :(ω -> ($(ok(x)) >= $(ok(a))) && ($(ok(x)) <= $(ok(b))))
  RandVar{Bool}(e, allωids)
end

## Functions of Random Variables
## =============================
"Approximate expectation of `x` with `nsamples`"
function expectation(x::RandVar{<:Real}, nsamples=1000)
  exp = 0.0
  xjl = compile(x)
  for i = 1:nsamples
    newω = Omega(Dict())
    exp += Base.invokelatest(xjl, newω)
  end
  exp/nsamples
end

"Project `y` onto the randomness of `x`"
function curry(x::RandVar, y::RandVar{T})::RandVar{RandVar{T}} where {T}
  inner = :(ω2 -> $(ok(y))(merge(ω2, ω1)))
  e1 = :(RandVar{$T}($(Meta.quot(inner)), $(ωids(y))))
  e = :(ω1 -> $e1)
  RandVar{RandVar{T}}(e, ωids(x))
end

## Inference
## =========
"Sample from `x | y == true`"
function Base.rand(x::RandVar, y::RandVar{Bool})
  xjl = compile(x)
  yjl = compile(y)
  while true
    newω = Omega(Dict())
    if Base.invokelatest(yjl, newω) == true
      return Base.invokelatest(xjl, newω)
    end
  end
end

## Test
## ====
θ = uniform(0, 1) ## ω -> ω[1]
expectation(θ)
x = normal(θ, 1)  ## ω -> invcdf(ω[2]) * 1 + θ
y = x ∈ [-2, -1]
y_ = curry(θ, x)
rand(y_)
rand(rand(y_))

cond_samples = [rand(θ, y) for i = 1:1000]

using Plots
histogram(cond_samples)

rand(x)


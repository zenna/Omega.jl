using Distributions

"Random Variable Ω -> T"
struct RandVar{T}
  expr::Expr
  ωids::Set{Int}
end

"Sample Space"
struct Omega
  d::Dict{Int, Float64}
end

function Base.getindex(ω::Omega, i)
  ω.d[i] = get(ω.d, i, rand())
end

"Compile `r` to julia function"
compile(r::RandVar) = eval(r.expr)

global ωcounter = 1
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

ωids(x) = Set{Int}()
ωids(x::RandVar) = x.ωids

function uniform(a, b, ωid=ωnew())
  allωids = union(Set(ωid), ωids(a), ωids(b))
  e = :(ω -> ω[$ωid] * ($b - $a) + $a)
  RandVar{Real}(e, allωids)
end

function invcdf(p)
  n = Normal(0, 1)
  quantile(n, p)
end

ok(x::Real) = x
ok(x::RandVar) = :($(x.expr)(ω))

function normal(μ, σ, ωid=ωnew())
  allωids = union(Set(ωid), ωids(μ), ωids(σ))
  e = :(ω -> invcdf(ω[$ωid]) * $(ok(σ)) + $(ok(μ)))
  RandVar{Real}(e, allωids)
end

"Sample from `x` conditioned on `y == true`"
function Base.rand(x::RandVar, y::RandVar)
  xjl = compile(x)
  yjl = compile(y)
  while true
    newω = Omega(Dict())
    if Base.invokelatest(yjl, newω) == true
      return Base.invokelatest(xjl, newω)
    end
  end
end

function Base.in(x::RandVar, ab::Vector)
  a, b = ab
  allωids = union(x.ωids, ωids(a), ωids(b))
  e = :(ω -> ($(ok(x)) >= $(ok(a))) && ($(ok(x)) <= $(ok(b))))
  RandVar{Bool}(e, allωids)
end

function expectation(x::RandVar{Real}, n=1000)
  exp = 0
  xjl = compile(x)
  for i = 1:n
    newω = Omega(Dict())
    exp += Base.invokelatest(xjl, newω)
  end
  exp/n
end

function highrv(x::RandVar, y::RandVar)
  ωx = x.ωids
  ωy = y.ωids
end 

"x(ω)"
(x::RandVar)(ω::Omega) = Base.invokelatest(compile(x), ω)

"Sample from `x`"
Base.rand(x::RandVar) = (ω = Omega(Dict()); x(ω))

## Test
newω = Omega(Dict())
θ = uniform(0, 1) ## ω -> ω[1]
expectation(θ)
x = normal(θ, 1)  ## ω -> invcdf(ω[2]) * 1 + θ
y = x ∈ [-2, -1]

cond_samples = [rand(θ, y) for i = 1:1000]

using Plots
histogram(cond_samples)

rand(x)


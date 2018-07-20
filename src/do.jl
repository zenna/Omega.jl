
@context ChangeCtx

@primitive function (x::RandVar)(ω::Ω) where {__CONTEXT__ <: ChangeCtx}
  println("Overdubbed")
  @show x.id
  rv = if x.id in keys(__context__.metadata)
    @show "false"
    __context__.metadata[x.id]
  else
    @show true
    x
  end
  args = Cassette.overdub(ChangeCtx(metadata = __context__.metadata), map, a->apl(a, ω), rv.args)
  Cassette.overdub(ChangeCtx(metadata = __context__.metadata), rv.f, ω[rv.id], args...)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function change(θold::RandVar, θnew::RandVar, x::RandVar{T}) where T
  f = ω -> Cassette.overdub(ChangeCtx(metadata = Dict(θold.id => θnew)), x, ω)
  RandVar{T}(f)
end

function test()
  Θ = normal(0.0, 1.0)
  x = normal(Θ, 1.0)
  @show Θ.id
  @show x.id
  dox = change(Θ, normal(100.0, 1.0), x)
  rand(dox)
end

# passdata = []
# @context PassCtx
# mypass = Cassette.@pass (ctx, sig, cinfo) -> (push!(passdata, (ctx = ctx, sig = sig, cinfo = cinfo)); cinfo)
# Θ = normal(0.0, 1.0)
# X = normal(Θ, 1.0)
# Cassette.overdub(PassCtx(pass=mypass), rand, X)

# Test nested
# @context Ctx1

# @prehook (f::Any)(args...) where {__CONTEXT__ <: Ctx1} = println("In Ctx1")

# g(x) = @overdub(Ctx1(), sin(1))

# @context Ctx2

# @prehook (f::Any)(args...) where {__CONTEXT__ <: Ctx2} = println("In Ctx2")

# @overdub(Ctx2(), g(3))

# h(x) = g(x)

# Q1 Can we differentiate X by type?
# - No because randvars with same type maybe different rvs
# - if we  added Id then maybe we could
# I need to override the behaviour of X
# If I could override the behaviour of thetaold(omega) from within X then
# if i did it by type it would clash with anyhting of the same type, which is wrong
# 


"""
Causal intervention: set `x1` to `x2`

`intervene` is equivalent to `do` in do-calculus

## Returns
operator(xold::RandVar{T}) -> xnew::RandVar{T}
where 

jldoctest
```
x = uniform(0.0, 1.0)
y = uniform(x, 1.0)
z = uniform(y, 1.0)
o = intervene(y, uniform(-10.0, -9.0))
```
"""
function intervene(x1::RandVar{T}, x2::Union{RandVar{T}, T}) where T
  dointervene(y, _) = y
  function dointervene(y::RandVar{T2, P}, seen::ObjectIdDict = ObjectIdDict()) where {T2, P}
    if y ∈ keys(seen)
      return seen[y]
    end
    args = map(y.args) do arg
      if arg === x1
        x2
      else
        dointervene(arg, seen)
      end
    end
    answer = if all(args .=== y.args)
      y
    else
      RandVar{T2, P}(y.f, args)
    end
    seen[y] = answer
  end
end

intervene(x1, x2, y::RandVar) = intervene(x1, x2)(y)

function intervene(x1, x2, model::RandVar...)
  o = intervene(x1, x2)
  map(o, model)
end
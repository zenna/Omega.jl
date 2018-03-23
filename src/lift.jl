# Lift functions of type T to RandVar{T}

# Base.in(x, ab::Interval) = x >= ab.a && x <= ab.b
# Base.in(x::Union{RandVar, Any}, ab::Union{RandVar{Interval}, Interval) = RandVar{Bool}(ω -> apl(x, ω) ∈ apl(x, ab), ωids(x))

## One idea is for any operaton on random variables
## e.g. x + y where  x or y are rand vars
## Look up the corresponding types e.g. Float64 + Float64
## And create the corresponding randvar

uniform(a, b, ωid=ωnew()) =
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)

uniform(a, b, ωid=ωnew()) =
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)
  
uniform(a, b, ωid=ωnew()) =
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)

Base.:-(a::RandVar{T}, b::T) where T = 
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)

Base.:-(a::T, b::RandVar{T}) where T = 
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)

Base.:-(a::RandVar{T}, b::RandVar{T}) where T =
  RandVar{Real}(ω -> uniform(apl(a, ω), apl(b, ω), ω, ωid), ωid)

function Base.:+(x::Union{RandVar, Any}, y::Union{RandVar, Any})
  ωids = union((Mu.ωids(arg) for arg in [x, y])...)
  RandVar{Real}(ω -> +(apl(x, ω), apl(y, ω)), ωids)
end

function lift(f::Function, domain::Vector{DataType}, range::Type):
  "Code Generation to lift `f` to act on `RandVar`s"
  @generated function lifted(args...)
    quote
      ωids = union((Mu.ωids(arg) for arg in [x, y])...)
      RandVar{Real}(ω -> +(apl(x, ω), apl(y, ω)), ωids)
    end
  end
end

"Code Generation to lift `f` to act on `RandVar`s"
function lift(f::Function, domain::Vector{DataType}, range::Type)
  argnames = [Symbol(:x, i) for i = 1:length(domain)]
  @show signature = map(argnames, domain) do nm, dom
    :($nm::Union{RandVar{$dom}, $dom})
  end
  return signature

  quote
    function $f(x::Union{RandVar, Any}, y::Union{RandVar, Any})
      ωids = union((Mu.ωids(arg) for arg in [x, y])...)
      RandVar{Real}(ω -> +(apl(x, ω), apl(y, ω)), ωids)
    end
  end
end

lift(Base.:+, [Any, Any], Bool)

f = g ∘ h

x_h -> (g ∘ h)(x_h)

f(x) = g(h(x))

ff(x) = x_ -> g(h(merge(x, x_)))
---[f]--->[g]---->

----------->
function gf(x)
  x_ -> g(h(x), x_)
end

function f(x, y)
  g(h(x), y)
end

function f(x)
  function _(y)
    g(h(x), y)
  end
end

function f(y)
  function _(x)
    g(h(x), y)
  end
end
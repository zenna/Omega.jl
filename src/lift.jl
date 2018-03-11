# Base.in(x, ab::Interval) = x >= ab.a && x <= ab.b
# Base.in(x::Union{RandVar, Any}, ab::Union{RandVar{Interval}, Interval) = RandVar{Bool}(ω -> apl(x, ω) ∈ apl(x, ab), ωids(x))

## One idea is for any operaton on random variables
## e.g. x + y where  x or y are rand vars
## Look up the corresponding types e.g. Float64 + Float64
## And create the corresponding randvar

function Base.:+(x::Union{RandVar, Any}, y::Union{RandVar, Any})
  ωids = union((Expect.ωids(arg) for arg in [x, y])...)
  RandVar{Real}(ω -> +(apl(x, ω), apl(y, ω)), ωids)
end

function lift(f::Function, domain::Vector{DataType}, range::Type):
  "Code Generation to lift `f` to act on `RandVar`s"
  @generated function lifted(args...)
    quote
      ωids = union((Expect.ωids(arg) for arg in [x, y])...)
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
      ωids = union((Expect.ωids(arg) for arg in [x, y])...)
      RandVar{Real}(ω -> +(apl(x, ω), apl(y, ω)), ωids)
    end
  end
end

lift(Base.:+, [Any, Any], Bool)
## Lifting
## =======

elemtype(x::T) where T = T
elemtype(::AbstractRandVar{T}) where T = T

"Make a random variable"
function mkrv(f, args::Tuple)
  elemtypes = map(elemtype, args)
  ms = methods(f, elemtypes)
  length(ms) =! 1 && throw(MethodError(f, elemtypes))
  RT = first(Base.return_types(f, elemtypes))
  RandVar{RT, false}(f, args)
end

# No Exists{T} yet https://github.com/JuliaLang/julia/issues/21026#issuecomment-306624369"

function lift(fnm::Union{Symbol, Expr}, n)
  args = [Symbol(:x, i) for i = 1:n]
  quote
  function $fnm($(args...), x::Mu.RandVar, xs...)
    mkrv($fnm, ($(args...), x, xs...))
  end
  end 
end

fs = [:(Base.:-),
      :(Base.:+),
      :(Base.:*),
      :(Base.:/),
      :(Base.:^),
      :(Base.:sin),
      :(Base.:cos),
      :(Base.:tan)]

const MAXN = 4
for f in fs, n = 1:MAXN
  eval(lift(f, n))
end


## Custom Lifts
## ============

function Base.:(==)(x::AbstractRandVar, y)
  RandVar{Bool, false}(≊, (x, y))
end

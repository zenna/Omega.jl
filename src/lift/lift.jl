## Lifting
## =======

elemtype(x::T) where T = T
elemtype(::AbstractRandVar{T}) where T = T

"Make a random variable"
function mkrv(f, args::Tuple)
  elemtypes = map(elemtype, args)
  ms = methods(f, elemtypes)
  length(ms) =! 1 && throw(MethodError(f, elemtypes))
  RTS = Base.return_types(f, elemtypes)
  isempty(RTS) && throw(ArgumentError("No return types"))
  RandVar{first(RTS), false}(f, args)
end

# No Exists{T} yet https://github.com/JuliaLang/julia/issues/21026#issuecomment-306624369"
function liftnoesc(fnm::Union{Symbol, Expr}, isrv::NTuple{N, Bool}) where N
  args = [isrv ?  :($(Symbol(:x, i))::Omega.AbstractRandVar) : Symbol(:x, i)  for (i, isrv) in enumerate(isrv)]
  quote
  function $fnm($(args...))
    Omega.mkrv($fnm, ($(args...),))
  end
  end
end

function liftesc(fnm::Union{Symbol, Expr}, isrv::NTuple{N, Bool}) where N
  args = [isrv ?  :($(Symbol(:x, i))::Omega.AbstractRandVar) : Symbol(:x, i)  for (i, isrv) in enumerate(isrv)]
  quote
  function $(esc(fnm))($(args...))
    Omega.mkrv($(esc(fnm)), ($(args...),))
  end
  end
end

function lift(fnm::Union{Expr, Symbol}, n::Integer; mod::Module=@__MODULE__())
  combs = rvcombinations(n)
  for comb in combs
    Core.eval(mod, liftnoesc(fnm, comb))
  end
end

function lift(f; n=3, mod::Module=@__MODULE__())
  lift(:($f), n; mod=mod)
end

## Pre Lifted
## ==========

fnms = [:(Base.:-),
        :(Base.:+),
        :(Base.:*),
        :(Base.:/),
        :(Base.:^),
        :(Base.:sin),
        :(Base.:cos),
        :(Base.:tan),
        :(Base.sum),
        :(Base.:&),
        :(Base.:|),
        :(Base.:sqrt),
        :(Base.:abs),
        :(Base.getindex),
        :(Base.:(==)),
        :(Base.:>),
        :(Base.:>=),
        :(Base.:<=),
        :(Base.:<),
        ]

Base.:^(x1::Omega.AbstractRandVar{T}, x2::Integer) where T = RandVar{T, false}(^, (x1, x2))
macro lift(fnm::Union{Symbol, Expr}, n::Integer)
  combinations = Iterators.product(((true,false) for i = 1:n)...)
  combinations = Iterators.filter(any, combinations)
  Expr(:block, map(comb -> liftmacro(fnm, comb), combinations)...)
end

"Combinations of RV or Not RV"
function rvcombinations(n)
  combinations = Iterators.product(((true,false) for i = 1:n)...)
  Iterators.filter(any, combinations)
end

const MAXN = 4
for fnm in fnms, i = 1:MAXN
  lift(fnm, i)
end
using .NonDet: URandVar, RandVar, reify

# Lifting Functions on type T to fnuctions on T-typed NonDet #

# No Exists{T} yet https://github.com/JuliaLang/julia/issues/21026#issuecomment-306624369"
function liftnoesc(fnm::Union{Symbol, Expr}, isrv::NTuple{N, Bool}) where N
  args = [isrv ?  :($(Symbol(:x, i))::RandVar) : Symbol(:x, i)  for (i, isrv) in enumerate(isrv)]
  quote
  function $fnm($(args...))
    Omega.lift($fnm)($(args...))
  end
  end
end

function liftesc(fnm::Union{Symbol, Expr}, isrv::NTuple{N, Bool}) where N
  args = [isrv ?  :($(Symbol(:x, i))::RandVar) : Symbol(:x, i)  for (i, isrv) in enumerate(isrv)]
  quote
  function $(esc(fnm))($(args...))
    Omega.lift($fnm)($(args...))
  end
  end
end

"Updates methods of `mod` to add lifted counterparts to function with name fnm"
function lift!(fnm::Union{Expr, Symbol}, n::Integer;
               mod::Module = @__MODULE__())
  # @show mod
  combs = rvcombinations(n)
  for comb in combs
    Core.eval(mod, liftnoesc(fnm, comb))
  end
end

function lift!(f; n=3, mod::Module = @__MODULE__())
  lift!(:($f), n; mod=mod)
end

# macro lift(fnm::Union{Symbol, Expr}, n::Integer)
#   combinations = Iterators.product(((true,false) for i = 1:n)...)
#   combinations = Iterators.filter(any, combinations)
#   Expr(:block, map(comb -> liftmacro(fnm, comb), combinations)...)
# end

"Combinations of RV or Not RV"
function rvcombinations(n)
  combinations = Iterators.product(((true,false) for i = 1:n)...)
  Iterators.filter(any, combinations)
end

# Pre Lifted #

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
        :(Base.:exp),
        :(Base.:log),
        # :(Base.getindex),
        # :(Base.:(==)),
        :(Base.:>),
        :(Base.:>=),
        :(Base.:<=),
        :(Base.:<),
        :(Base.:!),
        ]

const MAXN = 4
for fnm in fnms, i = 1:MAXN
  lift!(fnm, i)
end

# lift(f::Function) = (args...) -> ciid(f, args...)

@inline liftciid(f, args...) = URandVar(liftreifyapply, (f, args...))
@inline liftreifyapply(ωπ, f, args...) = f(reify(ωπ, args)...)

@generated function maybelift(f, args...)
  if any([arg <: RandVar for arg in args])
    :(liftciid(f, args...))
  else
    :(f(args...))
  end
end

lift(f) = (args...) -> maybelift(f, args...)

# Special Cases $
"""Lifted equality:
x ==ᵣ y results in a Boolean valued random variable which asks is the
__realization__ (hence subscript r) of `x` equal to `y`
If either `x` (or `y`) is a constant (not a RandVar) then it determines if
realization of `x` (or `y`) is equal to y (or `x`)"""
x ==ᵣ y = lift(==)(x, y)
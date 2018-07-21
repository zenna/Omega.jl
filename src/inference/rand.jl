"Unconditional Sample from `x`"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}; ΩT::Type{T} = defaultomega()) where T <: Ω
  x(ΩT())
end

"Unconditional Sample from `x`"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}, n::Int; ΩT::Type{T} = defaultomega()) where T <: Ω
  [x(ΩT()) for i = 1:n]
end


# const DefaultΩ = Omega.SimpleΩ{Omega.Paired, Omega.Float64}
const DefaultΩ = Omega.SimpleΩ{Omega.Paired, Omega.ValueTuple}
defaultomega() = DefaultΩ

defaultomega(::Type{ALG}) where ALG = DefaultΩ

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}, y, alg::Type{ALG};
                   n::Integer = 1000,
                   ΩT::OT = defaultomega(ALG),
                   cb = default_cbs(n),
                   kwargs...) where {ALG, OT}
  map(x, rand(ΩT, y, alg; n = n, cb = cb, kwargs...))
end

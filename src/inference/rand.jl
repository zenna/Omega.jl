"Default inference algorithm"
defalg(args...) = FailUnsat

"Default Ω to use"
# defΩ(args...) = SimpleΩ{Vector{Int}, Any}
defΩ(args...) = LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Any}}

"Default projection"
defΩProj(args...; OT = defΩ(args...)) = ΩProj{OT, idtype(OT)}

"Default callbacks"
defcb(args...) = donothing

"Single sample form from `x`"
function Base.rand(x::RandVar;
                   alg::SamplingAlgorithm = defalg(x),
                   ΩT = defΩ(alg),
                   kwargs...)
  first(rand(Random.GLOBAL_RNG, x, 1, alg; ΩT = ΩT, kwargs...))
end

function Base.rand(rng::AbstractRNG,
                   x::RandVar;
                   alg::SamplingAlgorithm = defalg(x),
                   ΩT::Type{OT} = defΩ(alg),
                   kwargs...) where {OT <: Ω}
  first(rand(rng, x, 1, alg; ΩT = ΩT, kwargs...))
end


function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer,
                   alg::SamplingAlgorithm;
                   ΩT::Type{OT} = defΩ(alg),
                   kwargs...) where {OT <: Ω}
  logdensity = Omega.mem(logerr(indomainₛ(x)))
  ωsamples = rand(rng, ΩT, logdensity, n, alg; kwargs...) 
  map(ω -> applynotrackerr(Omega.mem(x), ω), ωsamples)
end


function Base.rand(x::RandVar,
                   n::Integer;
                   alg::SamplingAlgorithm = defalg(x),
                   ΩT::Type{OT} = defΩ(alg),
                   kwargs...) where {OT <: Ω}
  rand(Random.GLOBAL_RNG, x, n, alg; ΩT = ΩT, kwargs...)
end

function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer;
                   alg::SamplingAlgorithm = defalg(x),
                   ΩT::Type{OT} = defΩ(alg),
                   kwargs...) where {OT <: Ω}
  rand(rng, x, n, alg; ΩT = ΩT, kwargs...)
end

function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SamplingAlgorithm;
                   ΩT::Type{OT} = defΩ(alg),
                   kwargs...) where {OT <: Ω}
  rand(Random.GLOBAL_RNG, x, n, alg; ΩT = ΩT, kwargs...)
end

Base.rand(x::RandVar, y::RandVar, n; kwargs...) = rand(Random.GLOBAL_RNG, cond(x, y), n; kwargs...)
Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(Random.GLOBAL_RNG, cond(x, y); kwargs...)
Base.rand(rng::AbstractRNG, x::RandVar, y::RandVar, n; kwargs...) = rand(rng, cond(x, y), n; kwargs...)
Base.rand(rng::AbstractRNG, x::RandVar, y::RandVar; kwargs...) = rand(rng, cond(x, y); kwargs...)

Base.rand(x::UTuple{RandVar}, n::Integer; kwargs...) = rand(randtuple(x), n; kwargs...)
Base.rand(x::UTuple{RandVar}; kwargs...) = rand(randtuple(x); kwargs...)

Base.rand(x::UTuple{RandVar}, y::RandVar, n::Integer; kwargs...) = rand(randtuple(x), y, n; kwargs...)
Base.rand(x::UTuple{RandVar}, y::RandVar; kwargs...) = rand(randtuple(x), y; kwargs...)

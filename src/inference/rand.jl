"Default inference algorithm"
defalg(args...) = RejectionSample

"Default Ω to use"
# defΩ(args...) = SimpleΩ{Vector{Int}, Any}
defΩ(args...) = LinearΩ{Vector{Int}, Segment, Any}

"Default projection"
defΩProj(args...; OT = defΩ(args...)) = ΩProj{OT, idtype(OT)}

"Default callbacks"
defcb(args...) = donothing

"Sample `n` from `x`"
function Base.rand(x::RandVar, n::Integer; alg::SamplingAlgorithm = defalg(x), ΩT = defΩ(alg), kwargs...)
  rand(x, n, alg, ΩT; kwargs...)
end

"Sample 1 from `x`"
function Base.rand(x::RandVar; alg::SamplingAlgorithm = defalg(x), ΩT = defΩ(alg), kwargs...)
  first(rand(x, 1, alg, ΩT; kwargs...))
end

# "Sample from `x`"
# function Base.rand(x::RandVar, n::Integer, alg::SamplingAlgorithm, ΩT::Type{OT}; kwargs...) {OT <: Ω}
#   rand(x, n, alg, ΩT(); kwargs...)
# end


Base.rand(x::RandVar, y::RandVar, n; kwargs...) = rand(cond(x, y), n; kwargs...)
Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(cond(x, y); kwargs...)

Base.rand(x::UTuple{RandVar}, n::Integer; kwargs...) = rand(randtuple(x), n; kwargs...)
Base.rand(x::UTuple{RandVar}; kwargs...) = rand(randtuple(x); kwargs...)

Base.rand(x::UTuple{RandVar}, y::RandVar, n::Integer; kwargs...) = rand(randtuple(x), y, n; kwargs...)
Base.rand(x::UTuple{RandVar}, y::RandVar; kwargs...) = rand(randtuple(x), y; kwargs...)

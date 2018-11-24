struct RelandscapeAlg <: Algorithm end
const Relandscape = RelandscapeAlg()

using Flux: Params
using ZenUtils: @grab

# Outstanding
# Need to make sure omegas have same dimensions
# Implement optimize

function sin2d(x, y)
  cos(2 * \pi x)

vectorize(ω) = [x.data for x in values(ω)]

"ω in argmax_Ω(f) initialised at ωinit"
function argmax(f, ω::Ω)
  f(ω) # Init
  # @grab f
  # @grab ω
  ωvals = collect(values((ω)))
  # @grab ωvals
  for i = 1:1000
    # println("ω", ωvals)
    # @show i
    gs = Tracker.gradient(() -> f(ω), Params(ωvals))
    # @grab ωvals
    # @grab gs
    for ωvec in ωvals
      Δ = gs[ωvec]
      l = 0.000001
      # @show Δ, Δ * l
      Flux.Tracker.update!(ωvec, Δ * l)
    end
    # @show f(ω)
  end
  @show f(ω)
  ω
end

"Euclidean Distance between `ω1` and `ω2`"
function ωdist(ω1, ω2)
  # @show keys(ω1)
  # @show keys(ω2)
  # @pre keys(ω1) == keys(ω2)
  total = 0.0
  for i in keys(ω1)
    # FIXME: Should I be able to index ω by vector? i..e ω[i]?
    total += sum((ω1.vals[i] .- ω2.vals[i]).^2)
  end
  sqrt(total)
end

const ϵ = 0.0001
@inline kernel(x, y; beta = 1.0) = x^(beta * y)
@inline logkernel(logx, y; beta = 1.0) = logx > -ϵ ? logx + log((1 + y / exp(logx))) : logx

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(x::RandVar,
                   alg::RelandscapeAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {OT <: Ω}
  ωrand = ΩT()
  ω = ΩT()
  U(ω) = logkernel(logepsilon(indomain(x, ω)),  ωdist(ω, ωrand)) # kernel rename
  U(ωrand) # Init
  U(ω) # Init
  argmax(U, ω)
end

function Base.rand(x::RandVar,
                   n::Int,
                   alg::RelandscapeAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {OT <: Ω}
  samples = []
  for i = 1:n
    try
      sample = rand(x, alg, ΩT, cb = cb)
      push!(samples, sample)
    catch
    end
  end
  # [rand(x, alg, ΩT, cb = cb) for i = 1:n]
  samples
end

## Example 


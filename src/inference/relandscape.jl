struct RelandscapeAlg <: Algorithm end
const Relandscape = RelandscapeAlg()
using Rotations
using Flux: Params
using ZenUtils: @grab

# Outstanding
# Need to make sure omegas have same dimensions
# Implement optimize

# wow(x, y) = sin(x*100) * sin(y*100) * exp(sqrt(x^2 + y^2) /  π)
# wow2(x, y) = sin(sqrt(x^2 + y^2) * 10π)
# wow3(x, y) = (sin(10π * x) * sin(10π * y))^2

# sin2d(x, y) = cos(2π * x) = cos(2π * y)

# vectorize(ω) = [x.data for x in values(ω)]

# So this is a little janky but it might work
# Optimize in constrained space

"ω in argmax_Ω(f) initialised at ωinit"
function argmax(f, ω::Ω)
  f(ω) # Init
  # @grab f
  # @grab ω
  ωvals = collect(values((ω)))
  # @grab ωvals
  for i = 1:10000
    # println("ω", ωvals)
    # @show i
    gs = Tracker.gradient(() -> f(ω), Params(ωvals))
    # @grab ωvals
    # @grab gs
    for ωvec in ωvals
      Δ = gs[ωvec]
      l = 0.0001
      # @show Δ, Δ * l
      Flux.Tracker.update!(ωvec, Δ * l)
    end
    # @show f(ω)
  end
  @show f(ω)
  @show exp(f(ω))
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
  # Random phase
  unifs = rand(2)

  # Period, adjust per problem
  period = 10

  # Random rotation 
  r = rand(RotMatrix{2})

  # To bound betwee [0, 1]
  sawtooth(x) = x - floor(Flux.data(x))
  function wave(ω)
    res = 1.0

    # Each arrow only has one element
    vs = [x[1] for x in values(ω)]
    vs = sawtooth.(r * vs)
    for (i, v) in enumerate(vs)
      res *= sin((v + unifs[i]) * 2 * pi * period * 1/5) 
    end
    log((res)^2) # Work in log scale
  end
  ω = ΩT()
  # U(ω) = logerr(indomainₛ(x, ω)) + wave(ω)
  U(ω) = min(logerr(indomainₛ(x, ω)),  wave(ω))

  @grab U
  # @grab x
  @grab wave
  U(ω) # Init
  argmax(U, ω)
end

function Base.rand(x::RandVar,
                   n::Int,
                   alg::RelandscapeAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {OT <: Ω}
  samples = []
  i = 1
  while i < n
    # try
      sample = rand(x, alg, ΩT, cb = cb)
      push!(samples, sample)
      i += 1
      # @assert false
    # catch e
    #   @show e
    #   @assert false
    # end
  end
  # [rand(x, alg, ΩT, cb = cb) for i = 1:n]
  samples
end

## Example 


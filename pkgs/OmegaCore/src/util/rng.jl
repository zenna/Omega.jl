import Random
export duplicaterng

# Relevant threads
# https://discourse.julialang.org/t/parallel-mersenne-twister/27567
# https://discourse.julialang.org/t/future-randjump-peculiar-speed/34862
# https://discourse.julialang.org/t/reproducible-multithreaded-monte-carlo-task-local-random/35269

"""
Create's `n` rngs from rng using rand jump

Related threads:


```jldoctest
import Random
seed = 3
rng = Random.MersenneTwister(seed)
rngs = duplicaterng(rng, 4)
julia> rand.(rngs)
4-element Array{Float64,1}:
 0.8116984049958615 
 0.282977627325657  
 0.13715166493608555
 0.1710542488647211 
"""
function duplicaterng(rng::T, n) where T
  jmpamt = big(10)^20
  rngs = Vector{T}(undef, n)
  rngs[1] = rng
  for i in 2:n
    @inbounds rngs[i] = Future.randjump(rngs[i - 1], jmpamt)
  end
  rngs
end

duplicaterng(::Random._GLOBAL_RNG, n) =
  duplicaterng(Random.default_rng(), n)
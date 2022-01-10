module OmegaOptim

import OmegaCore: argmax

using Optim

"Simple initialization algorithm"
struct RandInit end

randinit(rng, ::BinaryChoice{Bool}) = rand(rng, Bool)
randinit(rng, ::BinaryChoice{T})  where {T <: Integer} = rand(rng, (zero(T), one(T)))
randinit(rng, ::Unit{T}) = rand(rng, T)

function randindepinit(rng, x)
  ω = defω()
end

function init(x)
end

function OmegaCore.argmax(ℓ, ω0, ::Optim.AbstractOptimizer)
  ## Step 1

end

function test()
  x = 1 ~ Interval(0, 10)
  y = 2 ~ Interval(0, 10)
  ℓ = x +ₚ y
  ω0 = LazyΩ(x => 0.3, y => 0.9)
  optimize(ℓ, ω0, )
end

## What's needed?

## Initialization
  # Like lazy Omega
  # Or execute the program
## Overload optimize or use different name?
## function linearize(x) = xs::AbstractArray -> genω(xs)

end # module

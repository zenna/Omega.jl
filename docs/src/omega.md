# Omega

As described in [models], random variables are thin wrappers around functions which take as input a value `ω::Ω`
We previously described `Ω` as a type of `AbstractRNG`.  This is true, but the full store is a bit more complex

## Ω

`Ω` is an abstract type which represents a [sample space](https://en.wikipedia.org/wiki/Sample_space) in probability theory.

```@docs
Ω
```

```@docs
SimpleΩ
```

## Samplers vs Random Variables

A sampler and a random variable have many similarities but are different.
To demonstrate the difference, we shall show the changes one has to make to turn a sampler into an Omega `RandVar`.

Create a sampler that 

```julia
x1() = rand() > 0.5
```

`x1` uses `Random.GLOBAL_RNG` in the background.  Instead, make it explicit:

```julia
julia> x2(rng::AbstractRNG) = rand(rng) > 0.5
julia> x2(Random.MersenneTwister())
false
```

Make a cosmetic change

```julia
julia> x2(rng::AbstractRNG) = rand(rng) > 0.5
julia> x2(Random.MersenneTwister())
false
```
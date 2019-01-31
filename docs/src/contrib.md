# Contribution

Omega makes a strict distrinction between the model and the inference algorithms.
This makes it easy to add new inference algorithms to Omega.

Here we will describe how to implement a very simple inference procedure: rejection sampling.

The first step is to define a new abstract type that sub types `Algorithm`

```julia
"My Rejection Sampling"
abstract type MyRejectionSample <: Algorithm end
```

Then add a method to `Base.rand` with the following type

```julia
"Sample from `x | y == true` with rejection sampling"
function Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{MyRejectionSample};
                   n = 100,
                   cb = default_cbs(n)) where {OT <: Ω}
```

- The first argument `ΩT::Type{OT}` is the type of Omega that will be passed through.
- `y::RandVar` is a random predicate that is being conditioned on
- `alg::Type{MyRejectionSample}` should be as written

The remaining arguments are optional `n` is the number of samples, and `cb` are callbacks

The implementation is then

```julia
"Sample from `x | y == true` with rejection sampling"
function Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{MyRejectionSample};
                   n = 100,
                   cb = default_cbs(n)) where {OT <: Ω}
  # Run all callbacks
  cb = runall(cb)

  # Set of samples in Omega to return
  samples = ΩT[]

  # The number which have been accepted
  accepted = 1
  i = 1
  while accepted < n
    ω = ΩT()
    if err(y(ω)) == 1.0
      push!(samples, ω)
      accepted += 1
      cb(RunData(ω, accepted, 0.0, accepted), IterEnd)
    else
      cb(RunData(ω, accepted, 1.0, i), IterEnd)
    end
    i += 1
  end
  samples
end
```
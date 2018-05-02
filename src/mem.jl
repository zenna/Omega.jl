"RandVar which has randomness memoized"
struct MemoizedRandVar{O, X}
  ω::O
  x::X
end

function mem(ω::Omega, ::Params)
end

## TODO: Saving / loading.  Use BSON!

save(ω::Omega, fname) = bson(fname, ω)


"RandVar which has randomness memoized"
struct MemoizedRandVar{O, X}
  ω::O
  x::X
end

function mem(ω::Ω, ::Params)
end

## TODO: Saving / loading.  Use BSON!

save(ω::Ω, fname) = bson(fname, ω)


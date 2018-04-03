struct LazyId
  d::Dict{Int, Id}
end


LazyId() = LazyId(Dict{Int, Int}())

getf!(d::Associative, i, f) = i ∈ keys(d) ? d[i] : d[i] = f()
# Fix type instability
Base.getindex(l::LazyId, i::Int) = getf!(l.d, i, ωnew)


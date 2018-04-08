"Lazy List of Ids"
struct LazyId
  d::Dict{Int, Id}
end
LazyId() = LazyId(Dict{Int, Int}())
Base.getindex(l::LazyId, i::Int) = get!(l.d, i, ωnew)
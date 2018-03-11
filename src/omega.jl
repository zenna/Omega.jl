"Sample Space"
struct Omega{T<:Real}
  d::Dict{Int, T}
end
Omega() = Omega(Dict{Int, Float64}())
ωids(ω::Omega) = Set(keys(ω))

"`ω[i]` memoized sample of `ith` dimension of `ω`"
function Base.getindex(ω::Omega{T}, i::Integer) where T
  ω.d[i] = get(ω.d, i, rand(T))
end

function update(ω::Omega, i::Integer, val::Real)
  ω2 = deepcopy(ω)
  ω2.d[i] = val
  ω2
end

global ωcounter = 1
"Unique dimension id"
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

"`ω[is[i]] = vals[i]` forall i"
function update(ω::Omega, is::Vector{Int}, vals::Vector{Real})
  foreach(is, vals) do i, val
    ω = update(ω, i, val)
  end
  ω
end

"Merge `ω1` and `ω2`, values in `ω2` take precedence"
function Base.merge(ω1::Omega, ω2::Omega)
  for (key, val) in ω2.d
    ω1 = update(ω1, key, val)
  end
  ω1
end

"Projection of `ω` onto `is` dimensions"
project(ω::Omega, is::Set{Int}) = Omega(Dict(i => ω[i] for i in is))
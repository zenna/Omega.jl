"Parameter Set"
struct Params{I, T}
  d::Dict{I, T}
end

Params() = Params{Symbol, Any}(Dict{Symbol, Any}())
Base.getindex(θ::Params{I}, i::I) where I = θ.d[i]
Base.setindex!(θ::Params{I}, v, i::I) where I = θ.d[i] = v 

function test()
  p = Params()
  p[:x] = 2x+1 + p[y]
end

## TODO: Saving / loading.  Use BSON!

function save(ω::Omega)
end

function testparam()
  θ = Params()
  θ[:x] = 5.0
  θ[:y] = uniform(0.0, 1.0) + θ[:x]
end



# TODO: Stable IDs from Omega
# Problem 1.  [@id] is global, but it need only be relative (maybe?!)
# Problem 2. randvar ids are global
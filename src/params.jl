import RunTools: Params

## Random Params
## =============
dag(v, ω) = v
dag(v::Params, ω) = v(ω)
gag(v, ω) = v
gag(v::RandVar, ω) = dag(v(ω), ω)
gag(v::Params, ω) = v(ω)

function (φ::Params)(ω::Omega)
  Params(Dict(k => gag(v, ω) for (k, v) in φ.d))
end
Base.rand(ω, φ::Params) = φ(ω)
Base.rand(φ::Params) = Base.rand(DefaultOmega(), φ)
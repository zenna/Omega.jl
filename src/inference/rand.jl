"Unconditional Sample from `x`"
Base.rand(x::UTuple{RandVar}, OmegaT::T = DefaultOmega) where T = x(OmegaT())

# const DefaultOmega = Mu.SimpleOmega{Mu.Paired, Mu.Float64}
const DefaultOmega = Mu.SimpleOmega{Mu.Paired, Mu.ValueTuple}

"Version A"
Base.rand(x::RandVar, OmegaT::T = DefaultOmega) where T = x(OmegaT())
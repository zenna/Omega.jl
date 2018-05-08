using Flux
function Flux.Dense(ω::Mu.Omega, in::Integer, out::Integer, σ = identity;
                    initW = (ω, dims) -> logistic(ω, 0.0, 0.1, dims),
                    initb = (ω, dims) -> logistic(ω, 0.0, 0.1, dims))
  initW_ = initW(ω[@id], (out, in))
  initb_ = initb(ω[@id], (out,))
  Dense(initW_, initb_, σ)
end

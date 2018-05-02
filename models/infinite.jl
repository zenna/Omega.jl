using Mu

k = poisson(5)

function components(ω)
  a = Float64[(normal(ω[@id][i], 0.0, 1.0)) for i = 1:k(ω)]
  b = Float64[(normal(ω[@id][i], 0.0, 1.0)) for i = 1:k(ω)]
  vcat(a, b)
end

c = iid(components, Vector{Float64})
rand(c, sum(c) == 1.0)
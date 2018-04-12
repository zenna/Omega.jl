using Mu

k = uniform(1:4)

d = normal(0.0, 1.0)

function components(ω)
  a = Float64[(normal(ω[@id], 0.0, 1.0)) for i = 1:k(ω)]
  b = Float64[(normal(ω[@id], 0.0, 1.0)) for i = 1:k(ω)]
  vcat(a, b)
end

c = iid(components, Vector{Float64})
rand(c, sum(c) == 1.0)
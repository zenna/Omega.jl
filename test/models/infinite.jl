using Mu

function test()
  @show "hello"
  Mu.LazyId()
end

macro id(fexpr::Expr)
  @show ωids = test()
  Expr(fexpr.head, map(esc, fexpr.args)..., ωids)
end

k = uniform(1:4)

function components(ω)
  a = [@id(normal(ω, 0.0, 1.0)) for i = 1:k(ω)]
  b = [@id(normal(ω, 0.0, 1.0)) for i = 1:k(ω)]
  a, b
end

# components = @mu [normal(0.0, 1.0) for i = 1:k]

c = Mu.RandVar{Vector{Float64}}(components) #FIXME: Infer type
rand((k, components), sum(components) == 1.0)
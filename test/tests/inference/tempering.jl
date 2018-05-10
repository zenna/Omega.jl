using Mu
using UnicodePlots

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  β = kumaraswamy(0.1, 5.0)
  k = Mu.kf1β(β)
  # α = uniform(0.0, 5.0)
  # α = 3.0
  # k = Mu.kseα(α)
  n = 5000000
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(OmegaT, ≊(x, y, k), ALG;
                 n = n,
                 cb = [Mu.default_cbs(n);
                       throttle(Mu.plotrv(β, "Temperature: β"), 1);
                       throttle(Mu.plotω(x, y), 1);
                       throttle(Mu.plotrv(diff, "||x - y||"), 1)])
end

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  # β = kumaraswamy(0.1, 5.0)
  β = Mu.d(x, y)
  k = Mu.kf1β(β)
  n = 5000000
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(OmegaT, ≊(x, y, k), ALG;
                 n = n,
                 cb = [Mu.default_cbs(n);
                       throttle(Mu.plotrv(β, "Temperature: β"), 1);
                       throttle(Mu.plotω(x, y), 1);
                       throttle(Mu.plotrv(diff, "||x - y||"), 1)])
end

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  k = Mu.kpow
  k = Mu.kpareto2
  n = 5000000
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(OmegaT, Mu.ueq(x, y, k), ALG;
                 n = n,
                 cb = [Mu.default_cbs(n);
                      #  throttle(Mu.plotrv(β, "Temperature: β"), 1);
                       throttle(Mu.plotω(x, y), 1);
                       throttle(Mu.plotrv(diff, "||x - y||"), 1)])
end


μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
α = betarv(1.0, 2.0)
α = uniform(0.01, 1.6)

d(ω, x, y) = 1 - Mu.kse((x - y)^2; a = 0.01)
d(ω, x, y) = 1 - Mu.kse((x - y)^2; a = α(ω))

# samples = rand((μ, x, α, c), x == 10.0, HMC, n=10000)

c = Mu.randbool(iid(d, x, 4.0))

# samples = rand((μ, x, α, c), x == 4.0, HMC, n=250000)
samples = rand((μ, x, α, c), c, HMC, n=250000)

μs = (x -> x[1]).(samples)
xs = (x -> x[2]).(samples)
αs = (x -> x[3]).(samples)
cs = (x -> Mu.epsilon(x[4])).(samples)

function showstats(xs)
  println("Median is: ", median(xs))
  println("Mean is: ", mean(xs))
  println("std is: ", std(xs))
  println(lineplot(xs, width=140))
end

@show showstats(xs)
@show showstats(μs)
@show showstats(αs)
@show showstats(cs)


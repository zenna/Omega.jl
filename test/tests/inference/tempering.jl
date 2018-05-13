using Mu
using UnicodePlots

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  β = kumaraswamy(0.1, 5.0)
  k = Mu.kf1β(β)
  n = 10000
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
  k = Mu.burr
  n = 5000000
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(OmegaT, Mu.ueq(x, y, k), ALG;
                 stepsize=0.0001,
                 n = n,
                 cb = [Mu.default_cbs(n);
                      #  throttle(Mu.plotrv(β, "Temperature: β"), 1);
                       throttle(Mu.plotω(x, y), 1);
                       throttle(Mu.plotrv(diff, "||x - y||"), 1)])
end
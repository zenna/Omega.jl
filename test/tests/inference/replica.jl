module TestReplica
using Omega

function testreplica()
  x = normal(0.0, 1.0)
  y = normal(10.0, 3.0)
  whi = bernoulli(0.5) + 1
  z = randarray([x, y])
  a = z[whi]
  o = normal(a, 1.0)
  rand(a, o ==ₛ 23.0)
end

# testreplica()

function testreplica2()
  x = normal(0.0, 1.0)
  rand(x, x >ₛ 0.0, 1000; alg = Replica, swapevery = 10)
end

function testreplica3()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  samples = rand(x, x ==ₛ y, 1000; alg = Replica, swapevery = 10)
  (samples = samples, x = x, y = y)
  s = randtuple((x, y)).(samples)
  xs = [sa[2] for sa in s]
  ys = [sa[2] for sa in s]
  scatter(xs, ys)
end

function testreplica4()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  sam = withkernel(kseα(9.7448e9)) do
    rand(x, x ==ₛ y, 1000; alg = SSMH)
  end
  s = randtuple((x, y)).(sam)
  xs = [sa[2] for sa in s]
  ys = [sa[2] for sa in s]
  scatter(xs, ys)
end

function testreplica5()
  x = uniform(0.0, 1.0)
  c = ((x >ₛ 0.05) & (x <ₛ 0.15)) | ((x >ₛ 0.75) & (x <ₛ 0.85))
  # samples = withkernel(kseα(9.7448e9)) do
  #   samples = rand(x, c, 1000; alg = SSMH)
  # end
  samples = rand(x, c, 10000; alg = Replica, swapevery = 10)
  # (samples = samples, x = x, y = y)
  @show x.(samples)
  histogram(x.(samples), xlim = (0, 1), nbins=50)
end

function testreplica7(n; t = 1000, kwargs...)
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  xy = randtuple((x, y))
  c = abs(x) ==ₛ abs(y)
  s = withkernel(kseα(t)) do
    rand(xy, c, n; kwargs...)
  end
  # s = rand(randtuple((x, y)), c, 10000; alg = Replica, swapevery = 10, kwargs...)
  xs = [sa[1] for sa in s]
  ys = [sa[2] for sa in s]
  @show length(xs)
  scatter(xs, ys, xlim=(-1, 1), ylim = (-1, 1))
end



end
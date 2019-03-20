using Omega

function Y(rng, n)
  [normal(rng[@id], 0.0, 1.0) for i = 1:n]
end

# function test()
#   function x_(ω)
#     a = randexp(ω)
#     a2 = randexp(ω, (1, 2, 3))
#     b = randcycle(ω, 6)
#     c = randn(ω)
#     c2 = randn(ω, (1, 2, 3))
#     d = randstring(ω, 'a':'z', 6)
#     e = randsubseq(ω, collect(1:8), 0.3)
#     f = randperm(ω, 10)
#     (a, a2, b, c, c2, d, e, f)
#   end
#   x = ciid(x_)
#   lω = defΩ()()
#   x(lω)
# end

# test()
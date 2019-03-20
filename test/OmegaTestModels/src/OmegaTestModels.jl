"Models used to test Omega"
module OmegaTestModels
using Omega

function t1()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0) + normal(μ, 1.0)
  y = x ==ₛ 1.0
  (name = :t1, vars = (μ = μ, x = x, y = y), isfinite = true, isdiff = true, cond = y)
end

function t2()
  a = uniform(0.0, 1.0, 100)
  b = normal(0.0, 1.0)
  c = a * b
  y = c >ₛ 0.0
  (name = :t2, vars = (a = a, b = b, c = c, y = y), isfinite = true, isdiff = true, cond = y)
end

function t3()
  n = uniform(1:10)
  function x_(ω)
    x = normal(ω, 0, 1)
    for i = 1:n(ω)
      x += normal(ω, 0, 1)
    end
    x
  end
  x = ciid(x_)
  (name = :t3, vars = (x = x, n = n))
end

const allmodels = [
  t1(),
  t2(),
  t3()]


"`m` has key `k` and its true"
hastrue(m, k) = haskey(m, k) && m[k]

"Does `m` have a condition"
hascond(m) = haskey(m, :cond)
"is `m` differentiable"
isdiff(m) = hastrue(m, :isdiff)
"does `m` have a finite number of variables"
isfinite(m) = hastrue(m, :isfinite)


"""Conjoin predicates
  p = iseven ∧ (x -> x > 0) ∧ (x -> x < 100)
  p(50)
"""
function conjoin(preds::Vararg{Function})
  function pred_conjunct(x...)
    for pred in preds
      if !pred(x...)
        return false
      end
    end
    true
  end
  pred_conjunct
end
# zt: add spec

"`conjoin` ∧"
const ∧ = conjoin

export isfinite,
       isdiff,
       hascond,
       allmodels,
       ∧

end
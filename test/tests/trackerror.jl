module TestNamespace

using Omega

function testtrackerror()
  x = normal(0.0, 1.0)
  x_ = cond(x, x <ₛ 1.0)
  lt = x <ₛ 1.0
  Omega.applytrackerr(x_, Omega.defΩ()())
  gt = x >ₛ -1.0
  x__ = cond(x_, x >ₛ -1.0)
  Omega.applytrackerr(x__, Omega.defΩ()())
end
testtrackerror()

end
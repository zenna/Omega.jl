module TestNamespace

using Omega

function testtrackerror()
  x = normal(0.0, 1.0)
  x_ = cond(x, x ⪅ 1.0)
  lt = x ⪅ 1.0
  Omega.trackerrorapply(x_, Omega.defΩ()())
  gt = x ⪆ -1.0
  x__ = cond(x_, x ⪆ -1.0)
  Omega.trackerrorapply(x__, Omega.defΩ()())
end
testtrackerror()

end
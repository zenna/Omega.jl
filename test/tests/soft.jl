using Omega
using UnicodePlots

function softtest()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  coldsamples = withkernel(Omega.kseα(10.0)) do
    rand((x, y), x == y)
  end
  print(UnicodePlots.densityplot(ntranspose(coldsamples)...))

  hotsamples = withkernel(Omega.kseα(0.01)) do
    rand((x, y), x == y)
  end
  print(UnicodePlots.densityplot(ntranspose(hotsamples)...))
end

softtest()

function softtest2()
  # Test
  # x = iid(X)
  g(x::Bool) = x & x
  function f(ω)
    if Bool(ω > 0.35)
        g(ω > 0.5)
    else
      2ω <= 0.2
    end
  end
  ctx = Cassette.withtagfor(SoftExCtx(), f)
  ω = 0.5
  res = Cassette.overdub(ctx, f, ω)
end

softtest2()
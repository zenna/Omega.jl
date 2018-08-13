module TestNamespace

using Omega
using UnicodePlots

function softtest()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  coldsamples = withkernel(Omega.kseα(10.0)) do
    rand((x, y), x ≊ y, 1000)
  end
  print(UnicodePlots.densityplot(ntranspose(coldsamples)...))

  hotsamples = withkernel(Omega.kseα(0.01)) do
    rand((x, y), x ≊ y, 1000)
  end
  print(UnicodePlots.densityplot(ntranspose(hotsamples)...))
end

softtest()

end
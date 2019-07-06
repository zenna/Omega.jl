unitrng(; eps = 1e-5) = 0 + eps:0.005:1 - eps

function fx(xrv::RandVar;
            ΩT = defΩ(),
            xdim = 1,
            verbose = false)
  ω = ΩT()
  xrv(ω)
  function f(x)
    ω = Space.update(ω, xdim, x)
    y = xrv(ω)
    verbose && println(x, " -> ", y)
    y
  end
end

function fxy(xrv::RandVar;
                  ΩT = defΩ(),
                  xdim = 1,
                  ydim = 2)
  ω = ΩT()
  xrv(ω)
  function f(x, y)
    ω = Space.update(ω, xdim, x)
    ω = Space.update(ω, ydim, y)
    xrv(ω)
  end
end

"""
Contour Plot of two dimensions of Ω

```julia
using Omega
x = normal(0.0, 1.0)
y = normal(0.0, 1.0)
c1 = logerr(x ==ₛ y)
c2 = logerr(x >ₛ y)
ωcontour(c2)
```

"""
function ωcontour(xrv::RandVar;
                  ΩT = defΩ(),
                  xdim = 1,
                  ydim = 2,
                  xrng = unitrng(),
                  yrng = unitrng(),
                  plt = Plots.plot(),
                  fill = true,
                  aspect_ratio = 1,
                  kwargs...)
  ω = ΩT()
  xrv(ω)
  function f(x, y)
    ω = Space.update(ω, xdim, x)
    ω = Space.update(ω, ydim, y)
    @show xrv(ω)
  end
  Plots.contour!(plt, xrng, yrng, f; fill = fill, aspect_ratio = aspect_ratio, kwargs...)
end

function ωcontourmk(xrv::RandVar;
                  ΩT = defΩ(),
                  xdim = 1,
                  ydim = 2,
                  xrng = unitrng(),
                  yrng = unitrng(),
                  aspect_ratio = 1,
                  kwargs...)
  ω = ΩT()
  xrv(ω)
  function f(x, y)
    ω = Space.update(ω, xdim, x)
    ω = Space.update(ω, ydim, y)
    @show abs(xrv(ω)) / 20000
  end
  AbstractPlotting.surface(xrng, yrng, f; kwargs...)
end

# "x ∈ [0, 1]?"
# isunit(x) = 0.0 <= x <= 1.0

"Plot path in Omega Space from sequence of samples"
function ωtrace(ωs::Vector;
                   xdim = 1,
                   ydim = 2,
                   plt = plot())
  xs, ys = ntranspose(map(ω -> (getdim(ω, xdim), getdim(ω, ydim)), ωs))
  plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5, legend = false)  
end
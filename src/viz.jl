using Plots

"""
μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
y = x == 0.0
viz(y)
"""
function viz(y::Mu.RandVar, xdim, ydim, ω::Mu.Omega, xrng = 0:0.01:1, yrng = 0:0.01:1)
  ω_ = deepcopy(ω)
  function f(x_, y_)
    # @show x, y, ω_
    ω_.vals[xdim] = x_
    ω_.vals[ydim] = y_
    Mu.epsilon(y(ω_))
  end
  p = plot(xrng, yrng, f, st = [:surface, :contourf])
  # xcurr = ω_.vals[xdim]
  # ycurr = ω_.vals[xdim]
  # scatter!([xcurr], [ycurr])
end

isunit(x) = 0.0 <= x <= 1.0
function viz(ω, y::RandVar, xdim, ydim, xlb, xub, ylb, yub)
  @pre all(map(isunit, (xlb, xub, ylb, yub))...)

end
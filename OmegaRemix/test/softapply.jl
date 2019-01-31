using Omega
using OmegaRemix

function softtest2(ω = 0.39)
  g(x::Bool) = x & x
  function f(ω)
    if Bool(ω > 0.35)
      baba = ω > 0.5
      # @show typeof(baba)
      g(baba)
    else
      2ω <= 0.2
    end
  end
  softapply(f, ω)
end

function f(ω)
  if Bool(ω > 0.35)
    (baba, err) = ω >ₛ 0.5
    # @show typeof(baba)
    (res, err2) = g(baba)
    
  else
    2ω <= 0.2
  end
end

softtest2()

function softtest3()
  g(x::Real)::Bool = x > 0.5
  softapply(g, 0.3)
end

softtest3()
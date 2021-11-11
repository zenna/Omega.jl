using OmegaCore

function test()
  x = 1 ~ StdNormal{Float64}()
  y = 2 ~ StdUniform{Float64}()
  xy = @joint x y
  ω = OmegaCore.Space.LinearΩ([0.3, 0.5], OmegaCore.Tags(), Dict(x => 1, y => 2), [])
  xy(ω)
end

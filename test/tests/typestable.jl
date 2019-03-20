using Omega
using OmegaTestModels
using Test

OT = []
function teststable()
  for m in models, ΩT in ΩTs
    @test isconcretetype(m.y, elemtype(ΩT))
  end
end

teststable()
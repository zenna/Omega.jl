module TestNamespace

using Test
using Omega
using Callbacks: CbNode, idcb
using Lens
using Omega.Inference: Loop

function testcb()
  x = normal(0.0, 1.0)
  addz(data, stage) = (println("in addz"); (z = 1.0,))
  testz(data, stage) = (println("in testz"); @test haskey(data, :z))
  testnoz(data, stage) = (println("in testz"); @test !haskey(data, :z))

  cb = CbNode(idcb, (CbNode(addz, (testz,)), testnoz))
  rand(x, x >ₛ 0.0, 1, alg = HMCFAST, cb = cb)
  lenscall((Loop => cb,), rand, x, x >ₛ 0.0, 1, alg = HMCFAST)
end

testcb()

end
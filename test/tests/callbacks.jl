module TestNamespace

using Test
using Omega
using Callbacks: CbNode, idcb
using Lens
using Omega.Inference: Loop

function testcb()
  x = normal(0.0, 1.0)
  addz(data) = (println("in addz"); (z = 1.0,))
  testz(data) = (println("in testz"); @test haskey(data, :z))
  testnoz(data) = (println("in testz"); @test !haskey(data, :z))

  cb = CbNode(idcb, (CbNode(addz, (testz,)), testnoz))
  lenscall((Loop => cb,), rand, x, x >ₛ 0.0, 1, alg = HMCFAST)
end

testcb()

end
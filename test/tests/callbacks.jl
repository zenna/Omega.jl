using Test
import Omega.Inference: CbNode

function testcb()
  x = normal(0.0, 1.0)
  addz(data, stage) = (println("in addz"); (z = 1.0,))
  testz(data, stage) = (println("in testz"); @test haskey(data, :z))
  testnoz(data, stage) = (println("in testz"); @test !haskey(data, :z))

  cb = CbNode(Omega.idcb, (CbNode(addz, (testz,)), testnoz))
  rand(x, x ⪆ 0.0, 1, alg = HMCFAST, cb = cb)
end

testcb()
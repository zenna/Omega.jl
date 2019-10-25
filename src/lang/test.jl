using Test
import Omega.Lang: AppExpr, LetExpr
import Omega.Lang: unparse

function test1()
  op = """
  μ : uniform 0 1
  x : normal μ 1
  rand x + μ
  """
  oe = LetExpr(:μ, AppExpr(:uniform, [0, 1]),
              LetExpr(:x, AppExpr(:uniform, [0, 1]),
              AppExpr(:rand, )
              ))

  @test unparse(oe) == op
end

function test2()
  expr = quote
  function f(w)
    x = sqrt(w) + 1
    y = sqrt(x) + 3
    if

  end
end
proj(ω. id1) = id2 -> ω(pair(id, id))

# 1. in lazy omega, use interface ω[randvar] instead of ω.data[randvar] or ω[randvar]
# 2. make a new type which redefines getindex when paired

"""
`iid(i, x)`

Independent raandom variables
# Input
 idth element of sequence 
"""
iid(i, x) = ω -> x(proj(ω, id))

function test()
  function f(ω)
    a = 1 ~ Normal(ω, 0, 1)
    b = 2 ~ Normal(ω, 0, 1)
    a + b
  end

  function g(ω)
    x = 0.0
    for i = 1:100
      x += (i ~ f)(ω)
    end
    x
  end

  function h(ω)
    α = 1.0
    for i = 1:10
      α *= (i ~ f)(ω)
    end
    α
  end

  i(ω) = g(ω) + h(ω)

  ω = defω()
  i(ω)
  @test length(keys(ω)) == 240
end


## think about the semantics of ~?
## is it iid as abovesso is it CIID
## and if we have iid above, then we need IID as before

StdNormal(ω) = ω[(StdNormal, 1)]

2 ~ StdNormal 
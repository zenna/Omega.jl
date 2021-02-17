using OmegaCore
using OmegaTest
using OmegaCore.Traits

using Test
using Distributions
using Random

function testtraits()
  ω = SimpleΩ(Dict())
  ω2 = OmegaCore.appendscope(ω, [1,])
  # traits(typeof(ω2.tags))
  g(traits(typeof(ω2)))
end


function testsimple1()
  ω = defΩ()()
  ω = OmegaCore.tagrng(ω, Random.GLOBAL_RNG)
  ω2 = defΩ()()
  ω2 = OmegaCore.tagrng(ω2, Random.GLOBAL_RNG)
  x = 1 ~ Normal(0, 1)
  map(x, [ω, ω2])
end

function testsimple2()
  x = 1 ~ Normal(0, 1)
  rng = Random.GLOBAL_RNG
  ΩT = defΩ()
  y = OmegaCore.condvar(x)
  ω =  OmegaCore.OmegaRejectionSample.condomegasample1(rng, ΩT, y, OmegaCore.RejectionSample)
  x(ω)
end

function testsimple3a()
  x = 1 ~ Normal(0, 1)
  rng = Random.GLOBAL_RNG
  ΩT = defΩ()
  y = OmegaCore.condvar(x)
  ω =  OmegaCore.OmegaRejectionSample.condomegasample1(rng, ΩT, y, OmegaCore.RejectionSample)
  map(x, typeof(ω)[ω, ω])
end

function testsimple3()
  x = 1 ~ Normal(0, 1)
  rng = Random.GLOBAL_RNG
  ΩT = defΩ()
  y = OmegaCore.condvar(x)
  ω =  OmegaCore.OmegaRejectionSample.condomegasample1(rng, ΩT, y, OmegaCore.RejectionSample)
  x.([ω, ω])
end

function testsimple4()
  x = 1 ~ Normal(0, 1)
  rng = Random.GLOBAL_RNG
  ΩT = defΩ()
  y = OmegaCore.condvar(x)
  ω =  OmegaCore.OmegaRejectionSample.condomegasample(rng, ΩT, y, 5, OmegaCore.RejectionSample)
  map(x, ω)
end

@testset "infer types" begin
  @test isinferred(testsimple1)
  @test isinferred(testsimple2)
  @test isinferred(testsimple3)
  @test isinferred(testsimple3a)
  @test isinferred(testsimple4)
end  
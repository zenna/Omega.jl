using OmegaCore
using OmegaTest
using OmegaCore.Traits

using Test
using Distributions
using Random

function testsimple1()
  ω = defΩ()()
  ω = OmegaCore.tagrng(ω, Random.GLOBAL_RNG)
  ω2 = defΩ()()
  ω2 = OmegaCore.tagrng(ω2, Random.GLOBAL_RNG)
  x = 1 ~ StdNormal{Float64}()
  map(x, [ω, ω2])
end

function testsimple2()
  x = 1 ~ StdNormal{Float64}()
  rng = Random.GLOBAL_RNG
  OmegaCore.randsample(rng, x, 1; alg = RejectionSample)
end

function testsimple3a()
  x = 1 ~ StdNormal{Float64}()
  ω = defω()
  map(x, typeof(ω)[ω, ω])
end

function testsimple3()
  x = 1 ~ StdNormal{Float64}()
  ω = defω()
  x.([ω, ω])
end

function testsimple4()
  x = 1 ~ StdNormal{Float64}()
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
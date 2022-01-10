using OmegaCore
using Test
using Random
using OmegaCore.Tagging
using OmegaCore.Traits
using OmegaCore.RNG
using OmegaCore.TrackError

tagmersenne(ω) = tagrng(ω, Random.MersenneTwister())

@testset "tagging" begin

@testset "tagging1" begin
  ω = defΩ()()
  ω = tagmersenne(ω)
  ω = tagerror(ω, false)
  t_ = traits(ω)
  @test t_ == Trait{Union{Err, Rng}}()
end

@testset "tagging2" begin
  ω = defΩ()()
  ω2 = tagmersenne(ω)
  f(x::trait(Rng)) = 1
  f(_) = 2
  @test f(traits(ω)) == 2
  @test f(traits(ω2)) == 1
  @test isinferred(f, traits(ω))
  @test isinferred(f, traits(ω2))
end

@testset "tagging3" begin
  ω = defω()
  f(x::trait(Cond, Rng)) = 1
  f(x::trait(Cond, Mem)) = 2
  @test_throws MethodError f(ω)
end

@testset "tagging4" begin
  ω = defΩ()()
  ω2 = tagmersenne(ω)
  f(x::trait(Cond, Rng)) = 1
  f(x::trait(Cond, Mem)) = 2
  @test_throws MethodError f(traits(ω2))
end

@testset "tagging5" begin
  ω = defΩ()()
  ω = tagmersenne(ω)
  ω = tagerror(ω, false)
  g(x::trait(Rng)) = 1
  g(x::trait(Err)) = 2
  @test_throws MethodError g(traits(ω))
end

end
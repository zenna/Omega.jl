using Test

include("tests.jl")

# Make sure the notebook runs without an error.
# NOTE: This does not test whether the notebook is correct or whether the Pluto project manager is working
# if only tests whether the notebook throws an error with the ReplicaExchange Project.toml dependencies.
@test try include(joinpath(pwd(), "..", "notebooks", "multimodal.jl")); true; catch; false; end
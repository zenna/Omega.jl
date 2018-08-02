using Documenter
using Omega

makedocs(
  modules = [Omega],
  authors = "Zenna Tavares, Javier Burroni, Edgar Minaysan, Rajesh Ragananthan, Armando Solar Lezama",
  format = :html,
  sitename = "Omega.jl",
  pages = [
    "Home"=>"index.md",
    "Basic Tutorial" => "basictutorial.md",
    "Modeling" => "model.md",
    "Inference"=>"inference.md",
    "Soft Execution"=>"soft.md",
    "Inference"=>"inferencealgorithms.md",
    "Conditioning" => "conditioning.md",
    "Higher Order Inference" => "higher.md",
    "Causal Inference" => "causal.md",
    "Built-in Distributions" => "distributions.md",
    "Contribution Guide" => "contrib.md",
  ]
)

deploydocs(
  repo = "github.com/zenna/Omega.jl.git",
  julia="0.7",
  deps=nothing,
  make=nothing,
  target="build",
)

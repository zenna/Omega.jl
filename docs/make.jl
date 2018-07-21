using Documenter
using Omega

makedocs(
  modules = [Omega],
  authors = "Zenna Tavares, Javier Burroni, Edgar Minaysan, Rajesh Ragananthan, Armando Solar Lezama",
  format = :html,
  sitename = "Omega.jl",
  pages = [
    "Home"=>"index.md",
    "Getting started"=>"started.md",
    "Inference"=>"inference.md",
    "Basic Tutorial" => "basictutorial.md",
    "model" => "model.md",
    "Conditioning" => "conditioning.md",
    "Higher Order Inference" => "higher.md",
    "Causal Inference" => "causal.md",
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

using Documenter
using Mu

makedocs(
  modules = [Mu],
  authors = "Zenna Tavares, Javier Burroni, Edgar Minaysan, Rajesh Ragananthan, Armando Solar Lezama",
  format = :html,
  sitename = "Mu.jl",
  pages = [
    "Home"=>"index.md",
    "Getting started"=>"started.md",
    "Inference"=>"inference.md",
  ]
)

deploydocs(
  repo = "github.com/zenna/Mu.jl.git",
  julia="0.6",
  deps=nothing,
  make=nothing,
  target="build",
)

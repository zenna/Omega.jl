using Documenter
using Omega

makedocs(
  modules = [Omega],
  authors = "Zenna Tavares, Javier Burroni, Edgar Minaysan, Rajesh Ragananthan, Armando Solar Lezama",
  format = :html,
  sitename = "jl",
  pages = [
    "Home"=>"index.md",
    "Getting started"=>"started.md",
    "Inference"=>"inference.md",
  ]
)

deploydocs(
  repo = "github.com/zenna/jl.git",
  julia="0.6",
  deps=nothing,
  make=nothing,
  target="build",
)

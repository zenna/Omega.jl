using Documenter
using Mu

import Arrows: Props, AbstractArrow

makedocs(
  modules = [Arrows],
  authors = "Zenna Tavares, Javier Burroni, Edgar Minaysan, Rajesh Ragananthan",
  format = :html,
  sitename = "Mu.jl",
  pages = [
    "Home"=>"index.md",
    "Getting started"=>"started.md",
  ]
)


deploydocs(
  repo = "github.com/zenna/Mu.jl.git",
  julia="0.6",
  deps=nothing,
  make=nothing,
  target="build",
)

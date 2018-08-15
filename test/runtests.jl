using Omega
using Spec
using Test

include("lib/testlib.jl")

"""
Walk through `test_dir` directory and execute all tests, excluding `exclude`

```jldoctests
julia> using Spec
julia> walktests(Spec)
```
"""
function fakewalktests(testmodule::Module;
                   test_dir = joinpath(Pkg.dir(string(testmodule)), "test", "tests"),
                   exclude = [])
  print_with_color(:blue, "Running tests:\n")

  # Single thread
  srand(345679)
  with_pre() do
    for (root, dirs, files) in walkdir(test_dir)
      for file in files
        file ∈ exclude && continue
        fn = joinpath(root, file)
        println("Testing: ", fn)
        include(fn)
      end
    end
  end

  # print method ambiguities
  println("Potentially stale exports: ")
  display(Test.detect_ambiguities(testmodule))
  println()
end

fakewalktests(Omega)
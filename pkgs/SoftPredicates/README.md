# SoftPredicates

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://zenna.github.io/SoftPredicates.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://zenna.github.io/SoftPredicates.jl/dev)
[![Build Status](https://travis-ci.com/zenna/SoftPredicates.jl.svg?branch=master)](https://travis-ci.com/zenna/SoftPredicates.jl)
[![Codecov](https://codecov.io/gh/zenna/SoftPredicates.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/zenna/SoftPredicates.jl)

Soft predicates provides methods to relax methods.  It can be used for approximate inference and optimization -- to condition on constraints.

```julia
x = 10
y = 20
b = x ==ₛ y
ϵ:(0.0, -100000.0)
```

Soft Booleans can take part in logical operators
```julia
julia> notb = !b
ϵ:(-100000.0, 0.0)
```

Soft equality applies to vectors and arrays too:

```julia
x = rand(3, 3)
y = rand(3, 3)
x ==ₛ y
```

For other datatypes, by default soft equality will apply equality recursively on all the fields.
```julia
julia> struct X
         x
         y
       end

julia> X(1, 2) == X(3, 4)
false

julia> X(1, 2) == X(1, 2)
true

julia> recursofteq(X(1, 2), X(3, 4))
```
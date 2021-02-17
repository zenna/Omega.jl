export mapf
"""
`mapf(x, fs)`

Apply each function in `fs` to same input x
(f(x) for f in fs)
"""
mapf(x, fs) = map(f -> f(x), fs)

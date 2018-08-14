@spec all([res[i] = f[i](x) for f in fs])
applymany(fs, x) = map(xi->xi(x), fs)

"""
Transpose for nested list / tuples.  Useful for output of rand(::NTuple{RandVar})
  
```jldoctest
x = normal(0.0, 1.0)
y = normal(0.0, 1.0)
samples = rand((x, y), x == y)
x_, y_ = ntranspose(samples)
```
"""
ntranspose(xs) = [[x[i] for x in xs] for i = 1:length(xs[1])]
@post res[i, j]

"Counter"
mutable struct Counter
  count::Int
end
Counter() = Counter(0)

"Increment counter"
increment(c::Counter) = x::Int = c.count += 1

UTuple{T} = Tuple{Vararg{T, N}} where N

isjulia6() = v"0.6" <= VERSION < v"0.7-"
isjulia7() = VERSION > v"0.7-"

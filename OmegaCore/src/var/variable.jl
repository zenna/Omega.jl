export Variable

# # Variable
# A Variable is a parametric of random variable, which is just any function of
# ω::AbstractΩ.  We have this data structure because we need to intercept inner
# calls to `f(ω)`, which is difficult if it is not a special type and just a
# normal function

"A variable is just a function of ω."
struct Variable{F}
  f::F
end
recurse(f::Variable, ω) = f.f(ω)

Base.show(io::IO, f::Variable) = Base.print(io, "ᵛ", f.f)
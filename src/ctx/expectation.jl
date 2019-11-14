function test()
  x = normal(0, 1)
  y = y + 5
  mean(y)
end

function test()
  x(ω) = normal(ω, 0, 1)
  mean(x)
end

struct SymbolicΩ
  x::Dunno
end

normal(ω::SymbolicΩ, args...) = (f = normal, args = args)
mean()

# Idea 1 is to basically do a symbolic exection
# Create a symbolic omega type
# redefine all ops on it
# +(x::Symbolic, y::Symbolic) = 
# Then if I want to compute an expectaiton I analyze the graph
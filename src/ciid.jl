# How to make this

struct RandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
  f::F      # Function (generally Callable)
  args::TPL
  id::I
  indeps::SetRandVar
end

function (rv::RandVar{T, true})(ω::SimpleOmega) where T
  caller_ = caller(rv, ω) # Find out which random variable is calling ω, could be none
  if owns(caller_, rv)  # If caller_
  end
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(ω[rv.id], args...)
end


"""`RandVar` distrbuted according to `x`, but conditionally
independent given `y`"""
function ciid(x, y)
  # Conditionally independent of `x` given `y`
  # Y is shared, if I don't want to share y then it would need to, maybe we can do that from
  # X with the accumulation of ids

  # How could we NOT SHARE IT?
  # if an rv is in Y it means it Is shared.
  # Which means we reset the ids
end

A = poisson(5)
B(ω) = A(ω) + 10.0  
C(ω) = B(ω) + A(ω)
D = iid(C)  # i.i.d of C
E = ciid(D, A)  # shares D's A

# Problem 1 How to make D iid
# Conceptually I would (i) make a copy of C, and go through it and replace
# The i.d. of A in copy(C) with a new id.
# I can't do this in reality because I don't have access to A in C
# Instead, somehow when I call A from within C, I need to use a new id.

# Clarifying, when we do X(ω), we have the opportunity to add some metadata.
# Currnetly, if we add ids which accumulate into sequence of integers
# X.f(ω[1][2][3]) == X.f(ω[1,2,3])
# When we call rand(ω): this id is what is stored as the index in omega
# And with that index we control Omega

# Therefore if when we call A(ω) from within D, if we put on some unique id
# A.f(ω[uniqueid]), then this will make an independent A

# Crucially, if we put on A.f(ω[C.id, A.id]) then it will be
# independent with respect to C calling A

# Problem (a) Once we are inside C calling A, we have lost the information
# That C called A

# We have lost it because we throw away the actual random variable from the indices
# Sol: Have index store randvar
# Use a custom hash to make shit fast

# Problem (b)
# What rules are there

# As A, if I am being called and I know that C is the callee
# If D is IID then I should use label w[D][A]
# if D is not IID, just a normal child, then I should use my normal identity w[A]
# - If I were to use w[D][A] it would lead to inconsistent results
# - remember w[D][A] is really constructing a new independent random variable
# - it is a hack, of sorts

# We should have a function parent(A, D), which basically will return
# A with its id changed to whatever D would call A with

"Get `x` as parent of `y`"
function parent(x::RandVar{T}, y)::RandVar{T}
  
end

# Conceptually there is another different object
# Even though when calling A from C we want to just use the id A
# The call stack is still C, B, A
# Should we retain the call stack?
# There are two separate questins: (i) What is the call stack (ii) What id should we use to index omega
# When calling A from C rather than D, we want to use the id of A as stated before
# How do we know this. What distinguishes C from D

# Possibility:
# C Doesn't add itself to ids but D does
# This seems problematic if we call rand from within C and then should B add itself to ids or not?
# Presumably not



# Problem (b) 
function test1()
  x1 = normal(0.0, 1.0)
  x2 = ciid(x1)
  x1_, x2_ = rand((x1, x2))
  @test x1_ != x2_
end

""
function test2()
  x1 = normal(0.0, 1.0)
  x1 = x1 + 0.0
  x2 = ciid(x1)
  x1_, x2_ = rand((x1, x2))
  @test x1_ != x2_
end

function test2()
  x1 = normal(0.0)
  x2 = normal(0.0)
  x3 = x1 + x2
  x4 = ciid(x1)
  x4_, x3_ = rand((x3, x4))
  @test x4_ != x3_ 
end

function test3()
  x1 = normal(0.0, 1.0)
  x2 = normal(x1, 1.0)
  x3 = ciid(x2)

  # How to test they have the same parent?
  @test x4_ != x3_ 
end
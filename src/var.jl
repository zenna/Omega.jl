"Mutable Variable of type `T`"
mutable struct Var{T}
  val::T
end

Base.:+(x::Var, y::Var) = x.val + y.val
Base.:+(x::Var, y) = x.val + y
Base.:+(x, y::Var) = x + y.val

Base.:*(x::Var, y::Var) = x.val * y.val
Base.:*(x::Var, y) = x.val * y
Base.:*(x, y::Var) = x * y.val

function testvar()
  a = Var(1.0)
  f(x) = a + x
  a.val = 30
end
## Could either be like a RandVar
## Or be like a simple thing just that stores a value and can be motuated
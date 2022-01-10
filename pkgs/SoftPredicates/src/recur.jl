# @generated function recursofteq(x::T, y::T) where T
#   fieldnames(T)
#   all((softeq(x[]) )
# end

function recursofteq(x::T, y::T) where T
  allₛ([softeq(getfield(x, fn), getfield(y, fn)) for fn in fieldnames(T)])
end
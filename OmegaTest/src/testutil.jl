export isinferred

function isinferred(f, args...; allow = Union{})
  ret = f(args...)
  inftypes = Base.return_types(f, Base.typesof(args...))
  rettype = ret isa Type ? Type{ret} : typeof(ret)
  rettype <: allow || rettype == Test.typesubtract(inftypes[1], allow)
end

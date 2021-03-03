export isinferred

if VERSION > v"1.6-"
  const ts = Test.typesplit
else
  const ts = Test.typesubtract
end

function isinferred(f, args...; allow = Union{})
  ret = f(args...)
  inftypes = Base.return_types(f, Base.typesof(args...))
  rettype = ret isa Type ? Type{ret} : typeof(ret)
  rettype <: allow || rettype == ts(inftypes[1], allow)
end
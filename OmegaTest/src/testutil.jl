export isinferred

if VERSION > v"1.6-"
  function isinferred(f, args...; allow = Union{})
    true
  end
else
  function isinferred(f, args...; allow = Union{})
    ret = f(args...)
    inftypes = Base.return_types(f, Base.typesof(args...))
    rettype = ret isa Type ? Type{ret} : typeof(ret)
    rettype <: allow || rettype == Test.typesubtract(inftypes[1], allow)
  end
end
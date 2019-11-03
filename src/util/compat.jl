if VERSION <= v"1.2"
  # Just return the expression (i.e. eval in single thread)
  macro spawn(expr)
    expr
  end
  macro spawn(expr, rest...)
    expr
  end
else
  using Base.Threads: @spawn
end
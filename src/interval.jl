struct Interval
  a
  b
end

Base.in(x, ab::Interval) = x >= ab.a && x <= ab.b
Base.in(x::RandVar, ab::Interval) = RandVar{Bool}(ω -> x(ω) ∈ ab, ωids(x))
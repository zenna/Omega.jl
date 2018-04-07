using Mu

struct MyType
  x
end

Mu.lift(MyType; mod=Main)
MyType(uniform(0, 1)

struct YourType{T}
  x::T
end

Mu.lift(YourType, n=1, mod=Main)

x = YourType(uniform(0.0,1.0))
rand(x)

using Mu

struct OK{T}
  x::T
end

Base.:*(x::OK, y) = OK(x.x * y)
Base.:*(x, y::OK) = OK(x * y.x)

Base.:+(x::OK, y) = OK(x.x + y)

Base.:+(x::OK, y::OK) = OK(x.x + y.x)
Base.:-(x::OK, y::OK) = OK(x.x - y.x)

Base.:<(x::OK, y::OK) = softlt(x.x, y.x)
Base.:>(x::OK, y::OK) = softgt(x.x, y.x)
Base.:<(x, y::OK) = softlt(x, y.x)
Base.:<(x::OK, y) = softlt(x.x, y)

Base.Bool(x::SoftBool) = Bool(round(epsilon(x)))

function Base.rand(ωπ::Mu.OmegaProj{Mu.SimpleOmega{Int64,Mu.OK},Int64}, ::Type{T}) where T
  get!(()->OK(rand(Random.GLOBAL_RNG, T)), ωπ.ω.vals, ωπ.id)
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T},  dims::Dims) where {T, I, V <: OK, O <: SimpleOmega{I, V}}
  @show "hi"
  @show V
  @assert false "Not implemented (blocking to prevent silent errors)"
  
end

function X_(ω)
  x = uniform(ω, 0.0, 1.0)
  if Bool(2.0 * x > 3.0)
    3.0 * x
  elseif Bool(4.0 * x < 1.0)
    2.0 * x + 10.0
  else
    2.0 * x
  end
end

function X2_(ω)
  x = uniform(ω, 0.0, 1.0, (10,))
  y = sum(x)
  if Bool(2.0 * x > 3.0)
    3.0 * x
  elseif Bool(4.0 * x < 1.0)
    2.0 * x + 10.0
  else
    2.0 * x
  end
end

function testwow()

  # X1 = iid(X_)
  X2 = iid(X2_)


  ω = SimpleOmega{Int, OK}()

  X(ω)

  X2(ω)

  # rand((X1, X2), X1 == X2, HMCFAST)
end


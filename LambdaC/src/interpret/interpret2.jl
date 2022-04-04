module Interpret2
using ..LambdaC: AExpr
export empty_env, Environment
import MLStyle

const Environment = NamedTuple
empty_env() = NamedTuple()

"Produces new environment Γ' s.t. `Γ(x) = v` (and everything else unchanged)"
update(Γ, x::Symbol, v) = merge(Γ, NamedTuple{(x,)}((v,)))

function interpret_assign(aex, Γ)
  x = aex.args[1] # Variable that we're updating
  v = aex.args[2] # Value that we're updating it to
  Γ_ = update(Γ, x, v)
end

function interpret_program(aex, Γ)
  aex.head == :program || error("Must be a program aex")
  for stmt in aex.args
    Γ = interpret_assign(stmt, Γ)
  end
  return Γ
end

prim_to_func = Dict(:+ => +,
                    :- => -,
                    :* => *,
                    :/ => /)

isprim(f) = f in keys(prim_to_func)
primapl(f, x...) = prim_to_func[f](x...)

function interpret(aex, Γ)
  arr = [aex.head, aex.args...]
  next(x) = interpret(x, Γ)
  isaexpr(x) = x isa AExpr
  MLStyle.@match arr begin
    [:program, args...]                            => (AExpr(:assign, x, interpret(v, Γ)), Γ)
    [:assign, x, v::AExpr]                         => (AExpr(:assign, x, interpret(v, Γ)), Γ)
    [:assign, x, v::Symbol]                        => (AExpr(:assign, x, interpret(v, Γ)), Γ)
    [:assign, x, v]                                => (AExpr(:assign, x, v), update(Γ, x, v))
    s::Symbol                                      => (Γ[x], Γ)
    [:if, true, t, e]                              => (t, Γ)
    [:if, false, t, e]                             => (e, Γ)
    [:if, i::AExpr, t, e]                          => (AExpr(:if, interpret(i, Γ), t, e), Γ)
    [:call, f, args...] && if !isprim(f) end       => (AExpr(:call, next(f), args...), Γ)
    [:call, f, args...] && if any(isaexpr, args) end  => (AExpr(:call, map((i, arg) -> i == shit ? next(arg) : arg)), Γ)
    [:call, f, args...] && isprim(f) end           => (primapl(f, args...), Γ)
    _                                              => error("Could not interpret $arr")
  end
end

# Interpret until termination
function interpret_terminate(aex, env)
  while !done(aex, env)
    aex, env = interpret(aex, env)
  end
  aex, env
end

function start(aex::AExpr)::Environment
  env = empty_env()
  aex_, env_ = interpret_terminate(aex, env)
  env_
end

function step(aex::AExpr, env::Environment)::Environment
  aex_, env_ = interpret_terminate(aex, env)
  env_
end

end
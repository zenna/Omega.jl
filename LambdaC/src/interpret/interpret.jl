module InterpretBig
using Base: Integer, Bool
using ..LambdaC: AExpr, @λc_str
export empty_env, Environment, interpret, init_interpret, std_env
import MLStyle
using SoftPredicates

const Environment = NamedTuple
empty_env() = NamedTuple()
std_env() = empty_env()# (unif = interpret(λc"(λ i (λ ω (ω i)))", empty_env()),)

"Produces new environment Γ' s.t. `Γ(x) = v` (and everything else unchanged)"
update(Γ, x::Symbol, v) = merge(Γ, NamedTuple{(x,)}((v,)))

# unif(i, ω) = ω[(:unif, i)]

# (let unif λ j (λ w (w j))
#          (let x (λ ω ((unif 1) ω))
#          (let ω (λ i (if (== i 1) then 0.2 else 0.5))
#            (x ω))))

prim_to_func = Dict(:+ => +,
                    :- => -,
                    :* => *,
                    :/ => /,
                    :& => &,
                    :! => !,
                    :| => |,
                    :> => >,
                    :>= => >=,
                    :< => <,
                    :<= => <=,
                    :(==) => ==,
                    :>ₛ => >ₛ)

isprim(f) = f in keys(prim_to_func)
primapl(f, x...) = prim_to_func[f](x...)


# For Lazy Evaluation
struct Closure
  env::Environment
  expr
end

clo(env, expr) = Closure(env, expr)

function arg(aex::AExpr)
  arr = [aex.head, aex.args...]
  MLStyle.@match arr begin
    [:fn, arg, body]                                       => arg
    _                                                      => error("Could find body of $arr")
  end
end

function body(aex::AExpr)
  arr = [aex.head, aex.args...]
  MLStyle.@match arr begin
    [:fn, arg, body]                                       => body
    _                                                      => error("Could find body of $arr")
  end
end

"substitute x for v withih expr"
function sub(aex::AExpr, (x, v))
  arr = [aex.head, aex.args...]
  # next(x) = interpret(x, Γ)
  isaexpr(x) = x isa AExpr
  MLStyle.@match arr begin
    [:fn, args, body]                                       => AExpr(:fn, args, sub(body, x => v))
    [:call, f, arg1] && if isprim(f) end                    => AExpr(:call, f, sub(arg1, x => v))
    [:call, f, arg1, arg2] && if isprim(f) end              => AExpr(:call, f, sub(arg1, x => v),  sub(arg2, x => v))
    [:if, c, t, e]                                          => AExpr(:if, sub(c, x => v), sub(t, x => v), sub(e, x => v))
    [:let, x, val, body] && if x ∉ keys(Γ) end              => AExpr(:let, x, val, sub(body, x => v))
    [:call, t1, t2]                                         => AExpr(:call, t1,  sub(t2, x => v))
    _                                                       => error("Could not sub $arr")
  end
end

sub(aex::Symbol, (x, v)) = aex == x ? v : aex
sub(aex::Real, (x, v)) = aex

function interpret(aex::AExpr, Γ::Environment)
  arr = [aex.head, aex.args...]
  # next(x) = interpret(x, Γ)
  isaexpr(x) = x isa AExpr
  MLStyle.@match arr begin
    [:fn, args, body]                                       => clo(Γ, aex)
    [:call, f, arg1] && if isprim(f) end                    => primapl(f, interpret(arg1, Γ))
    [:call, f, arg1, arg2] && if isprim(f) end              => primapl(f, interpret(arg1, Γ), interpret(arg2, Γ))
    [:if, c, t, e] && if interpret(c, Γ) == true end        => interpret(t, Γ)
    [:if, c, t, e] && if interpret(c, Γ) == false end       => interpret(e, Γ)
    [:let, x, val, body] && if x ∉ keys(Γ) end              => interpret(body, update(Γ, x, clo(Γ, val)))
    [:call, t1, t2]                                         => let clo_ = interpret(t1, Γ),
                                                                   v1 = interpret(t2, Γ)
                                                                 interpret(sub(body(clo_.expr), arg(clo_.expr) => v1), clo_.env)
                                                                end
    _                                                       => error("Could not interpret $arr")
  end
end

function interpret(x::Symbol, Γ::Environment)
  if x == Symbol("false")
    false
  elseif x == Symbol("true")
    true
  else
    MLStyle.@match x begin
      x::Symbol  && if x ∈ keys(Γ) end                        => interpret(Γ[x].expr, Γ[x].env)
      _                                                       => error("Could not interpret $x")
    end
  end
end

interpret(x::Integer, Γ) = x
interpret(x::AbstractFloat, Γ) = x
interpret(x::Bool, Γ) = x

init_interpret(aex) = interpret(aex, std_env())

## Soft Cosntraints

struct CtxVal
  val
  ctx
end

a ⊕ b = error()

function soft_interpret(expr, Γ, ctx)
  arr = [aex.head, aex.args...]
  # next(x) = interpret(x, Γ)
  MLStyle.@match arr begin
    [:fn, args, body]                                       => clo(Γ, aex)
    [:call, f, arg1] && if isprim(f) end                    => CtxVal(primapl(f, si(arg1, Γ, ctx).val), si(arg1, Γ, ctx).ctx)
    [:call, f, arg1, arg2] && if isprim(f) end              => let cv1 = si(arg1, Γ, ctx),
                                                                   cv2 = si(arg2, Γ, cv1.ctx)
                                                                   fx = primapl(f, cv1.val, cv2.val)
                                                                   CtxVal(fx, cv2.ctx) # zt : do we need this composition?
                                                                end
    [:if, c, t, e] && if si(c, Γ, ctx).val == true end      => si(t, Γ, si(c, Γ, ctx).ctx)
    [:if, c, t, e] && if si(c, Γ, ctx).val == false end     => si(e, Γ, si(c, Γ, ctx).ctx)
    [:let, x, val, body] && if x ∉ keys(Γ) end              => interpret(body, update(Γ, x, clo(Γ, val)))
    [:call, t1, t2]                                         => let clo_ = interpret(t1, Γ), v1 = interpret(v2, Γ) ; interpret(sub(body(clo_.expr), x => v1), clo_.env) end
    [:cond, t1, t2, ωt]                                     => let ℓ = i(t2, Γ),
                                                                   ω = i(ωt, Γ)
                                                                   si(Γ ∧ ℓ)
                                                              end
    _                                                       => error("Could not interpret $arr")
  end
end

soft_interpret(x::Integer, Γ, ctx) = CtxVal(x, ctx)
soft_interpret(x::AbstractFloat, Γ, ctx) = CtxVal(x, ctx)
soft_interpret(x::Bool, Γ, ctx) = CtxVal(x, ctx)
# end

const si = soft_interpret

end
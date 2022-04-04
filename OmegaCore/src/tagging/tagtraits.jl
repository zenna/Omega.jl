
import ..Traits
using ..Traits: Trait
export Err,
       LogEnergy,
       Mem,
       Intervene,
       Rng,
       Scope,
       Cond,
       Propose,
       RandMutate,
       IgnoreCondition,
       Seen,
       Solve

# # Primitive Traits
struct Err end
struct LogEnergy end
struct Mem end
struct Intervene end
struct Rng end
struct Scope end
struct Cond end
struct Propose end
struct RandMutate end
struct IgnoreCondition end
struct Seen end
struct Solve end


function symtotrait(x::Symbol)
  if x == :err
    Err
  elseif x == :logenergy
    LogEnergy
  elseif x == :mem
    Mem
  elseif x == :intervene
    Intervene
  elseif x == :rng
    Rng
  elseif x == :scope
    Scope
  elseif x == :condition
    Cond
  elseif x == :ignorecondition
    IgnoreCondition
  elseif x == :propose
    Propose
  elseif x == :randmutate
    RandMutate
  elseif x == :seen
    Seen
  elseif x == :solve
    Solve
  else
    error("Unknown trait: $x")
  end
end

@generated function Traits.traits(k::Tags{K, V}) where {K, V}
  traits_ = map(symtotrait, K)
  Trait{Union{traits_...}}()
end

@generated function Traits.traits(k::Type{Tags{K, V}}) where {K, V}
  traits_ = map(symtotrait, K)
  Trait{Union{traits_...}}()
end
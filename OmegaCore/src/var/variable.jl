import AndTraits
export Variable, AbstractVariable, isvariable, traitvartype, AbstractClass, AbstractVariableOrClass, TraitIsVariableOrClass

abstract type AbstractVariableOrClass end

abstract type AbstractVariable <: AbstractVariableOrClass end

abstract type AbstractClass <: AbstractVariableOrClass end

# Traits
const TraitIsVariable = AndTraits.Trait{:TraitIsVariable}
const TraitIsClass = AndTraits.Trait{:TraitIsClass}
const TraitIsVariableOrClass = AndTraits.Trait{:TraitIsVariableOrClass}
const TraitUnknownVariableType = AndTraits.Trait{:TraitUnknownVariableType}

"Is `v` a variable?"
function isvariable(v::Function)
  mthds = methods(v)
  any(mthds.ms) do m
    # Core.println(m.sig)
    !(m.sig isa UnionAll) && length(m.sig.types) == 2 && (m.sig.types[2] == AbstractΩ)
  end
end

function isclass(v::Function)
  mthds = methods(v)
  any(mthds.ms) do m
    # Core.println(m.sig)
    !(m.sig isa UnionAll) && length(m.sig.types) == 3 && (m.sig.types[3] == AbstractΩ)
  end
end

function traitvartype_(f::Function)
  # Core.println(f)
  if isvariable(f)
    TraitIsVariable
  elseif isclass(f)
    TraitIsClass
  else
    TraitUnknownVariableType
  end
end

# @generated function traitvartype(f::Function)
#   traitvartype(f)
# end

@generated function traitvartype(f::Type{<:Function})
  functype = f.parameters[1]
  traitvartype_(functype.instance)
end


# By default we don't know the variable type
traitvartype(T) = TraitUnknownVariableType

traitvartype(::AbstractVariable) = TraitIsVariable
traitvartype(::Type{<:AbstractVariable}) = TraitIsVariable

# abstract type AbstractVariable end
# # Variable
# A Variable is a parametric or random variable, which is just any function of
# ω::AbstractΩ.  We have this data structure because we need to intercept inner
# calls to `f(ω)`, which is difficult if it is not a special type and just a
# normal function

"A variable is just a function of ω."
struct Variable{F} <: AbstractVariable
  f::F
end
recurse(f::Variable, ω) = f.f(ω)

Base.show(io::IO, f::Variable) = Base.print(io, "ᵛ", f.f)

struct Class{C} <: AbstractClass
  c::C
end
Var.traitvartype(::Class) = TraitIsClass
Var.traitvartype(::Type{<:Class}) = TraitIsClass

@inline (c::Class)(i, ω) = c.c(i, ω)
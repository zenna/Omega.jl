export Variable, AbstractVariable, isvariable, traitvartype

abstract type AbstractVariable end

# Traits
struct TraitIsVariable end
struct TraitIsClass end
struct TraitUnknownVariableType end
struct TraitIsNotVariable end

"Is `v` a variable?"
@generated function isvariable(v::Function)
  mthds = methods(v.instance)
  any(mthds.ms) do m
    # Core.println(m.sig)
    !(m.sig isa UnionAll) && length(m.sig.types) == 2 && (m.sig.types[2] == AbstractΩ)
  end
end

@generated function isclass(v::Function)
  mthds = methods(v.instance)
  any(mthds.ms) do m
    # Core.println(m.sig)
    !(m.sig isa UnionAll) && length(m.sig.types) == 3 && (m.sig.types[3] == AbstractΩ)
  end
end

function traitvartype(f::Type{<:Function})
  if isvariable(f.instance)
    # 31
    TraitIsVariable()
  elseif isclass(f.instance)
    TraitIsClass()
  else
    TraitIsNotVariable()
  end
end

@generated function traitvartype(f::Function)
  traitvartype(f)
end

@generated function traitvartype(f::Type{<:Function})
  func = t.parameters[1]
  traitvartype(func)
end


# By default we don't know the variable type
traitvartype(T) = TraitUnknownVariableType()

traitvartype(::AbstractVariable) = TraitIsVariable()
traitvartype(::Type{<:AbstractVariable}) = TraitIsVariable()

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
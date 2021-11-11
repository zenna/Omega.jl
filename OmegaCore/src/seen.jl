module SeenVars

using ..Traits, ..Tagging, ..Var
import ..Var

export tagseen

tagseen(ω, seen = Set()) = tag(ω, (seen = seen,))

function Var.posthook(::trait(Seen), ret, f::ExoRandVar, ω)
  println("does this handle i.i.d right?")
  push!(ω.tags.seen, f)
end


export ctxapply
function ctxapply(x, ω)
  ..
end

end
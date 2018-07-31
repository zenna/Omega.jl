
## Cassette Powered Intervention
## =============================

@context ChangeCtx

function Cassette.execute(ctx::ChangeCtx, x::RandVar, ω::Ω)
  if ctx.metadata.id === x.id
    return ctx.metadata.x(ω)
  else
    return Cassette.RecurseInstead()
  end
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function change(θold::RandVar, θnew::RandVar, x::RandVar{T}) where T
  f = ω -> Cassette.overdub(ChangeCtx(metadata = (id = θold.id, x = θnew)), x, ω)
  RandVar{T}(f)
end

"Change where `θconst` is not a randvar, but constant"
change(θold, θconst, x) = change(θold, constant(θconst), x)

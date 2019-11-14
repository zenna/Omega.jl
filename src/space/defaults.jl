
"Default Ω to use"
# defΩ(args...) = SimpleΩ{Vector{Int}, Any}
defΩ(args...) = LinearΩ{ID, UnitRange{Int64}, Vector{Any}}


"Default projection"
defΩProj(args...; OT = defΩ(args...)) = ΩProj{OT, idtype(OT)}

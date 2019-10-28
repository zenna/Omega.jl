
"Default Ω to use"
# defΩ(args...) = SimpleΩ{Vector{Int}, Any}
defΩ(args...) = LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Any}}


"Default projection"
defΩProj(args...; OT = defΩ(args...)) = ΩProj{OT, idtype(OT)}

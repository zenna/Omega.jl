inf(::Type{Float64}) = Inf64
inf(::Type{Float32}) = Inf32
inf(::Type{Float16}) = Inf16
# inf(::Type{T}) where {T <: ForwardDiff.Dual} = T(Inf)

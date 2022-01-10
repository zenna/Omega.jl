

# function record(data)
#   push!(data)
# end

# struct MemoryChannel{T}
#   x::Vector{T}
# end

# function (x::MemoryChannel{T})(c::Channel) where T
#   while true
#     v = rand(T)
#     push!(x.x, v)
#     put!(c, v)
#   end
# end

# mem = MemoryChannel([31])
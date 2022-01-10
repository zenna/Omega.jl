function anyₛ(xs::AbstractArray{T, N}) where {T <: SoftBool, N}
  SoftBool(maximum([sb.logerr for sb in xs]))
end

function allₛ(xs::AbstractArray{T, N}) where {T <: SoftBool, N}
  SoftBool(sum([sb.logerr for sb in xs]))
end

function anyₛ(xs::AbstractArray{T, N}) where {T <: DualSoftBool, N}
  b0 = allₛ([x.b0 for x in xs])
  b1 = anyₛ([x.b1 for x in xs])
  DualSoftBool(b0, b1)
end

function allₛ(xs::AbstractArray{T, N}) where {T <: DualSoftBool, N}
  b0 = anyₛ([x.b0 for x in xs])
  b1 = allₛ([x.b1 for x in xs])
  DualSoftBool(b0, b1)
end

softeq(a::AbstractArray, b::AbstractArray) = allₛ(softeq.(a, b))
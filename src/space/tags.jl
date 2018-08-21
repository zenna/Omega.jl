"Meta data to attach to ω::Ω"
struct Tags{K, V}
  tags::NamedTuple{K, V}
end

"Does tag type contain `t`, forall t in `tags`?"
hastags(::Type{Tags{K, V}}, tags::Symbol...) where {K, V} = all([t in K for t in tags])

# Merging

Base.merge(x::Tags, y::Tags) = merge(combinetag, x.tags, y.tags)
combinetag(::Type{Val{:replmap}}, a, b) = merge(a, b)
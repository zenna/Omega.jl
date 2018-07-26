struct TaggedΩ{I, T, ΩT, N} <: Ω{I}
  taggedω::ΩT
  tags::NamedTuple{N, T}
end

TaggedΩ(ω::ΩT, tags::NamedTuple{N, T}) where {N, I, T, ΩT <: Ω{I}} = TaggedΩ{I, T, ΩT, N}(ω, tags)

tag(ω::Ω, tag) = TaggedΩ(ω, tag)
tag(ω::TaggedΩ, tag) = TaggedΩ(ω.taggedω, merge(ω.tags, tag))

Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.taggedω, i), tω.tags)
Base.rand(tω::TaggedΩ, args...) = rand(tω.taggedω, args...)
Base.rand(tω::TaggedΩ, dims::Integer...) = rand(tω.taggedω, dims...)
Base.rand(tω::Omega.TaggedΩ, dims::Dims) = rand(tω.taggedω, dims)

parentω(tω::TaggedΩ) = TaggedΩ(parentω(tω), tω.tags)
"Meta data attached to ω::Ω"
struct Tag{K, V}
  tags::NamedTuple{K, V}
end

struct TaggedΩ{I, TAGS <: Tag, ΩT} <: Ω{I}
  taggedω::ΩT
  tags::TAGS
end

TaggedΩ(ω::ΩT, tags::TAGS) where {I, ΩT <: Ω{I}, TAGS} =
  TaggedΩ{I, TAGS, ΩT}(ω, tags)

tag(ω, tag_::NamedTuple) = tag(ω, Tag(tag_))
tag(ω, tag_::Tag) = TaggedΩ(ω, tag_)

proj(tω::TaggedΩ, x) = tag(proj(tω.taggedω, x), tω.tags)
tag(ω::TaggedΩ, tag) = TaggedΩ(ω.taggedω, merge(ω.tags, tag))

# mergetags(etag::ErrorTag, stag::ScopeTag) = 
#   HybridTag(stag.scope, etag.sbw)

# mergetags(stag::ScopeTag, etag::ErrorTag) = 
#   HybridTag(stag.scope, etag.sbw)

# mergetags(stag1::ScopeTag, stag2::ScopeTag) = 
#   ScopeTag(merge(stag1.scope, stag2.scope))

# mergetags(htag::HybridTag, stag::ScopeTag) = 
#   HybridTag(merge(htag.scope, stag.scope), htag.sbw)

# function tag(ω::TaggedΩ, tags)
#   TaggedΩ(ω.taggedω, mergetags(ω.tags, tags))
# end

Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.taggedω, i), tω.tags)
Base.rand(tω::TaggedΩ, args...) = rand(tω.taggedω, args...)
Base.rand(tω::TaggedΩ, dims::Integer...) = rand(tω.taggedω, dims...)
Base.rand(tω::Omega.TaggedΩ, dims::Dims) = rand(tω.taggedω, dims)
Base.rand(tω::Omega.TaggedΩ, arr::Array) = rand(tω.taggedω, arr)

parentω(tω::TaggedΩ) = TaggedΩ(parentω(tω), tω.tags)
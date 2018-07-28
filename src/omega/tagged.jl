abstract type Tag end

struct ErrorTag{E} <: Tag
  sbw::E
end

"Mapping from random variable to random variable which replaces it in interved model"
struct Scope{RV}
  idmap::Dict{Int, RV}
  # id::Int
  # rv::RV
end

struct ScopeTag{ID <: Scope} <: Tag
  scope::ID
end

struct HybridTag{ID <: Scope, E} <: Tag
  scope::ID
  sbw::E
end

# Tag = NamedTuple{N, T}

struct TaggedΩ{I, TAG <: Tag, ΩT} <: Ω{I}
  taggedω::ΩT
  tags::TAG
end

# 0.7 TaggedΩ(ω::ΩT, tags::Tag) where {N, I, T, ΩT <: Ω{I}} = TaggedΩ{I, TAG, ΩT}(ω, tags)
TaggedΩ(ω::ΩT, tags::TAG) where {I, TAG, ΩT <: Ω{I}} = TaggedΩ{I, TAG, ΩT}(ω, tags)

tag(ω::Ω, tag) = TaggedΩ(ω, tag)
# tag(ω::TaggedΩ, tag) = TaggedΩ(ω.taggedω, merge(ω.tags, tag))

mergetags(etag::ErrorTag, stag::ScopeTag) = 
  HybridTag(stag.scope, etag.sbw)

mergetags(stag::ScopeTag, etag::ErrorTag) = 
  HybridTag(stag.scope, etag.sbw)

function tag(ω::TaggedΩ, tags)
  TaggedΩ(ω.taggedω, mergetags(ω.tags, tags))
end

Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.taggedω, i), tω.tags)
Base.rand(tω::TaggedΩ, args...) = rand(tω.taggedω, args...)
Base.rand(tω::TaggedΩ, dims::Integer...) = rand(tω.taggedω, dims...)
Base.rand(tω::Omega.TaggedΩ, dims::Dims) = rand(tω.taggedω, dims)

parentω(tω::TaggedΩ) = TaggedΩ(parentω(tω), tω.tags)
"Meta data to attach to ω::Ω"
const Tags{K, V} = NamedTuple{K, V}

"Does tag type contain `t`, forall t in `tags`?"
hastags(::Type{Tags{K, V}}, tags::Symbol...) where {K, V} = all([t in K for t in tags])
combinetag(::Type{Val{:replmap}}, a, b) = merge(a, b)

"Sample space tagged with meta-data.  Enables `iid`, `replace`, `trackerror`"
struct TaggedΩ{I, TAGS <: Tags, ΩT} <: Ω{I}
  taggedω::ΩT
  tags::TAGS
  TaggedΩ(ω::ΩT, tags::TAGS) where {I, ΩT <: Ω{I}, TAGS} =
    new{I, TAGS, ΩT}(ω, tags)
end

hastags(::Type{TaggedΩ{I, TAGS, ΩT}}, tags...) where {I, TAGS, ΩT} = hastags(TAGS, tags...)

tag(ω, tag_::Tags) = TaggedΩ(ω, tag_)
tag(tω::TaggedΩ, tag_::Tags) = TaggedΩ(tω.taggedω, merge(combinetag, tag_, tω.tags))

# Pass-throughs (tω::TaggedΩ should work like its tω.taggedω, but preserve tags)

@inline Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.taggedω, i), tω.tags)
# Base.rand(tω::TaggedΩ, args...) = rand(tω.taggedω, args...; rng = rng(tω))

@inline Base.rand(tω::TaggedΩ) = rand(tω.taggedω; rng = rng(tω))
@inline Base.rand(tω::TaggedΩ, dim::Integer, dims::Integer...) = rand(tω.taggedω, dim, dims...; rng = rng(tω))
@inline Base.rand(tω::TaggedΩ, dims::Dims) = rand(tω.taggedω, dims; rng = rng(tω))
@inline Base.rand(tω::TaggedΩ, arr::Array) = rand(tω.taggedω, arr; rng = rng(tω))
@inline parentω(tω::TaggedΩ) = TaggedΩ(parentω(tω), tω.tags)
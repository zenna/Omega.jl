"Sample space tagged with meta-data.  Enables `iid`, `replace`, `trackerror`"
struct TaggedΩ{I, TAGS <: Tags, ΩT} <: Ω{I}
  taggedω::ΩT
  tags::TAGS
  TaggedΩ(ω::ΩT, tags::TAGS) where {I, ΩT <: Ω{I}, TAGS} =
    new{I, TAGS, ΩT}(ω, tags)
end

hastags(::Type{TaggedΩ{I, TAGS, ΩT}}, tags...) where {I, TAGS, ΩT} = hastags(TAGS, tags...)
  
tag(ω, tag_::Tags) = TaggedΩ(ω, tag_)
tag(ω, tag_::NamedTuple) = tag(ω, Tags(tag_))
tag(ω::TaggedΩ, tag_::NamedTuple) = tag(ω, Tags(tag_))
tag(tω::TaggedΩ, tag_::Tags) = TaggedΩ(tω.taggedω, Tags(merge(tag_, tω.tags)))

proj(tω::TaggedΩ, x) = tag(proj(tω.taggedω, x), tω.tags)
@spec _res.tags == tω.tags "tags are preserved in projection"

# Pass-throughs (tω::TaggedΩ should work like its tω.taggedω, but preserve tags)

Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.taggedω, i), tω.tags)
Base.rand(tω::TaggedΩ, args...) = rand(tω.taggedω, args...)
Base.rand(tω::TaggedΩ, dims::Integer...) = rand(tω.taggedω, dims...)
Base.rand(tω::Omega.TaggedΩ, dims::Dims) = rand(tω.taggedω, dims)
Base.rand(tω::Omega.TaggedΩ, arr::Array) = rand(tω.taggedω, arr)

Proj.parentω(tω::TaggedΩ) = TaggedΩ(parentω(tω), tω.tags)
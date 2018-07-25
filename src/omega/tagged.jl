struct TaggedΩ{I, T, ΩT, N} <: Ω{I}
  ω::ΩT
  tag::NamedTuple{N, T}
end

tag(ω::Ω, tag) = TaggedΩ(ω, tag)
tag(ω::TaggedΩ, tag) = TaggedΩ(ω.ω, merge(ω.tag, tag))

Base.values(tω::TaggedΩ) = values(tω.ω)
Base.keys(tω::TaggedΩ) = keys(tω.ω)

Base.getindex(tω::TaggedΩ, i) = TaggedΩ(getindex(tω.ω, i))

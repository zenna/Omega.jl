import ..Tagging: hastag, traithastag, tag, mergetag
import ..Util: mergef
import ..Traits: traits
export AbstractΩ, defΩ, defω, resolve, idtype, replacetags, like

# # Sample Space
# A sample space represents a set of possible values.
# Sample spaces are structured in the sense that that are composed of parts.
# Different parts are indicated by an id (see IDS)

"Abstract Sample Space"
abstract type AbstractΩ end

# # Tags
"""
`tag(ω::AbstractΩ, tags)`

tag `ω` with `tags`.
"""
function tag(ω::AbstractΩ, tags, mergefunc=mergetag)
  replacetags(ω, mergef(mergefunc, ω.tags, tags))
end

rmtag(ω::AbstractΩ, tag) =
  replacetags(ω, rmkey(ω.tags, tag))

updatetag(ω::AbstractΩ, tag, val) =
  replacetags(ω, update(ω.tags, tag, val))

traithastag(t::AbstractΩ, tag) = traithastag(t.tags, tag)
hastag(ω::AbstractΩ, tag) = hastag(ω.tags, tag)

traits(ω::AbstractΩ) = traits(tags(ω)) # FIXME: Do this at the type level

# function tags end

# # Defaults
"Default sample space"
function defΩ end

"Default sample space object"
function defω end

# FIXME MOve this somewhere (shouldnt really be in AbstractΩ)

function replacetags end

function resolve end

"`ids(ω)` Collection of ids in `ω`, i.e. domain of ω"
function ids end

function idtype end

function like end

function subspace end

"`proj(ω, ss)` Project `ω` onto subspace `ss`"
function proj end

## Updating Interface
export update
# "`update(ω, k, v)` returns ω' which is equvalent to ω except that `ω'[k] = v`"
# function update(ω, k, v) end

# "Equivalent to setindex!, returns mutated ω"
# function update!(ω, k, v) end

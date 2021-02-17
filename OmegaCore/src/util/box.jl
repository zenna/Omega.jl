import Future
export Box

"Mutable wrapper for a value"
mutable struct Box{T}
  val::T
end
mutable struct Box{T}
  val::T
end

@inline val(box::Box) = box.val
@inline val(ref::Ref) = ref.x
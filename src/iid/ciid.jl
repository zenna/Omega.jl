
"Construct an c.i.i.d. of `X`"
ciid(f; T=infer_elemtype(f)) = RandVar{T}(f)

# ciid(f, args...; T=infer_elemtype(f, args...)) = RandVar{T}(ω -> f(ω, args...))

"ciid with arguments"
ciid(f, args...; T=infer_elemtype(f, args...)) = RandVar{T, true}(f, args)
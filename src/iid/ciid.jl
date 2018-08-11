
"RandVar that is identically distributed to `f` but conditionally independent given parents`"
ciid(f; T = infer_elemtype(f)) = URandVar{T}(f)

"ciid with arguments"
ciid(f, args...; T = infer_elemtype(f, args...)) = URandVar{T}(f, args)
# Soft Conditioning

export softcond, |ₛ

"Soft condition `x` on `y`"
softcond(x, y)
@inline x |ₛ y = softcnd(x, y)
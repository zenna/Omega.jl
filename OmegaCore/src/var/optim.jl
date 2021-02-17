module Optim

"""
`argmax(v, ℓ)`

Find `ω` such that `v(ω) != ⊥` and ℓ(ω) is maximised
"""
function argmax end

"""
`solution(v)`

Find `ω` that satisfies constraints of `v` (`v(ω) != ⊥`)
"""
function solution end

end
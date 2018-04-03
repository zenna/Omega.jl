# Selection

Arrows has a few mechanisms to select `Port`s, `SubPort`s and various `Arrow` types.
Arrows.jl embraces unicode! The following symbols are used throughout:

- ▸ = `in_port`
- ◂ = `out_port`
- ▹ = `in_sub_port`
- ◃ = `out_sub_port`
- ⬧ = `port`
- ⬨ = `sub_port`

## Filtering Examples
These can be used to select filtering by boolean combinations of predicates

- `◂(arr, 1)`: The first out `Port`
- `▹(sarr, is(θp))`: all parametric in `SubPort`s
- `◂(carr, is(ϵ) ∨ is(θp), 1:3)`: first 3 `Port`s which are error or parametric

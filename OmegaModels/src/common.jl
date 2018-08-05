using Tensorboard
using FileIO

# To make this fast you could usue a generated function
"Update Tensorboard"
function uptb(writer, name, field, verbose = true)
  updateaccuracy(data, stage) = nothing # Do nothing in other stages
  function updateaccuracy(data, stage::Type{Outside})
    val = getfield(data, field)
    verbose && println("Saving $name to Tensoboard: $val")
    Tensorboard.add_scalar!(writer, name, val, data.i)
  end
end

savejld(val, path, i) = save("$path$i.jld2", Dict("data" => val))

"Save `data.field` to `path(data.i).jld2` as JLD2"
function savedatajld2(path, field, verbose = true)
  savejld2(data, stage) = nothing # Do nothing in other stages
  function savejld2(data, stage::Type{Outside})
    fn = "$path$(data.i).jld2"
    val = getfield(data, field)
    verbose && println("Saving $field to JLD2 file: $fn")
    save(fn, Dict(string(field) => val))
  end
end

## Std Inf Alg Params
"Optimization-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = SSMH
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"HMCFAST Specific Params"
function infparams_(::Omega.HMCFASTAlg)
  φ = Params()
  φ[:n] = uniform([200, 500, 1000, 10000])
  φ[:stepsize] = uniform([0.1, 0.01, 0.001])
  φ[:nsteps] =  uniform([100, 200, 500, 1000])
  φ[:takeevery] =  uniform([10])
  φ
end

function infparams_(any)
  φ = Params()
  φ
end

Omega.lift(:infparams_, 1)


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

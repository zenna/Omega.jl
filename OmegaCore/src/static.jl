# # StaticID

"ids used in `f(ω)`"
function modelids(f, ω)
end

"ids used in `f`"
function modelids(f)
end

function test_static()
  function f(ω)
    :x ~ Normal(0, 1)(ω)
    :y ~ Normal(0, 1)(ω)
  end
end

isstatic(f)
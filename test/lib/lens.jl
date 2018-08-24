module Lens

# Lens laws:
# get (put x y)   == x
# put x (put y z) == put x z
# put (get x) y   == y

export test_lens_get_put, test_lens_put_put, test_lens_put_get

function test_lens_get_put(get, put, containers, vals)
  passed = true
  for x in vals
    for y in containers
      passed &= get(put(x, y)) == x
    end
  end

  passed
end

function test_lens_put_put(get, put, containers, vals)
  passed = true
  for x in vals
    for y in vals
      for z in containers
        if put(x, put(y, z)) != put(x, z)
          println("x: " * string(x))
          println("y: " * string(y))
          println("z: " * string(z))
          println("LHS: " * string(put(x, put(y, z))))
          println("RHS: " * string(put(x, z)))
          println(put(x, put(y, z)) == put(x, z))
        end
        passed &= put(x, put(y, z)) == put(x, z)
      end
    end
  end

  passed
end

function test_lens_put_get(get, put, containers, vals)
  passed = true
  for x in containers
    for y in containers
      passed &= put(get(x), y) == y
    end
  end

  passed
end

end
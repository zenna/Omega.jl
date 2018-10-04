module Lens

# Lens laws:
# get (put x y)   == x
# put x (put y z) == put x z
# put (get x) y   == y
export test_lens_put_get, test_lens_put_put, test_lens_get_put

function test_lens_put_get(get, put, containers, vals)
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
        passed &= put(x, put(y, z)) == put(x, z)
      end
    end
  end
  passed
end

function test_lens_get_put(get, put, containers, vals)
  passed = true
  for x in containers
    passed &= put(get(x), x) == x
  end
  passed
end

end
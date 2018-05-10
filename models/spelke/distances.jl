# Point Set distances

"distance betwee two scenes"
function hausdorff(s1, s2, Δ = Δ)
  Δm(x, S) = minimum([Δ(x, y) for y in S])
  max(maximum([Δm(e, s2) for e in s1]), maximum([Δm(e, s1) for e in s2]))
end

"Helper function to iterate over all possible mappings for the surjection distance function."
function nextfunction(f, rng)
  shift = 0
  stop = false
  while !stop
    if shift == length(f)
      return f
    else  
      if f[end-shift] < (length(rng))
        f[end-shift] += 1
        stop = true
      else
        f[end-shift]=1
        shift += 1
      end
    end
  end
  return f
end

"Surjection distance"
function surjection(s1, s2, Δ = Δ)
  if length(s1) < length(s2)
    dom = s2
    rng = s1
  else
    dom = s1
    rng = s2
  end

  # Cycle through all surjections
  distance = NaN
  Surj = ones(length(dom))
  continue_ = true

  while continue_
    # Step 1: check if function is a surjection
    if length(unique(Surj)) == length(rng)
      # Step 2: compute distance and replace if necessary
      surjdist = sum([Δ(dom[x],rng[floor(Int,Surj[x])]) for x in range(1,length(dom))])
      if (surjdist < distance) | isnan(distance)
        distance = surjdist
      end
    end
    # Step 3: Get next function
    Surj = nextfunction(Surj, rng)
    if unique(Surj) == [length(rng)]
      continue_ = false
    end
  end
  return distance
end

"Fair surjection distance"
function fairsurjection(s1, s2, Δ = Δ)
  if length(s1) < length(s2)
    dom = s2
    rng = s1
  else
    dom = s1
    rng = s2
  end
  # Cycle through all surjections
  distance = NaN
  Surj = ones(length(dom))
  continue_ = true

  while continue_
    # Step 1: check if function is a surjection
    if length(unique(Surj)) == length(rng)
      
      # Step 1b: check that the surjection is fair.
      Spread = countmap(Surj)
      countedVals = [v for (k,v) in Spread]
      if maximum(countedVals)-minimum(countedVals) <= 1
        # Step 2: compute distance and replace if necessary
        surjdist = sum([Δ(dom[x],rng[floor(Int,Surj[x])]) for x in range(1,length(dom))])
        if (surjdist < distance) | isnan(distance)
          distance = surjdist
        end
      end
    end
    # Step 3: Get next function
    Surj = nextfunction(Surj, rng)
    if unique(Surj) == [length(rng)]
      continue_ = false
    end
  end
  return distance
end

"Sum of minimum distances"
function sumofmin(s1, s2, Δ = Δ)
  Δm(x, S) = minimum([Δ(x, y) for y in S])
  (sum([Δm(e, s2) for e in s1])+sum([Δm(e, s1) for e in s2]))/2
end

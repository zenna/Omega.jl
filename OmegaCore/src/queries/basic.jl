export expectation,
       𝔼

       import OmegaCore

"The expected value of a random variable"
function expectation end

function expectation(x; k = 100000)
  𝔼(x; k = 100000) = sum(OmegaCore.randsample(x, k)) / k
end

# Short hand
𝔼(x) = expectation(x)
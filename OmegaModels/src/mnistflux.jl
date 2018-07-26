using ZenUtils
using Omega
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle

const nimages = 3000
const imgs = MNIST.images()[1:nimages]
# Stack images into one large batch
const X = hcat(float.(reshape.(imgs, :))...) # |> gpu
const labels = MNIST.labels()[1:nimages]
# One-hot-encode the labels
const Y = onehotbatch(labels, 0:9) # |> gpu

function net_(ω)
  Chain(
    Dense(ω[@id], 28^2, 32, relu),
    Dense(ω[@id], 32, 10),
    softmax)
end

lift(:(Omega.SoftBool), 1)
lift(:(Flux.crossentropy), 2)

"Bayesian Multi Layer Percetron"
function mlp(; n = 10, alg = HMCFAST, randkargs...)
  net = ciid(net_; T=Flux.Chain)
  prediction = net(X)
  loss = crossentropy(prediction, Y)
  sb = Omega.SoftBool(loss)
  nets = rand(net, sb, n; alg = alg, randkargs...)
end

# Problem1.
# Using cross entropy as SoftBool when it is not actually a softbool, which is invalid
# in particular when aded with true itill become true

# 

# The problem is that net has no conditions,
# so HMC is asking for conditions, it gets back true effectively,
# and tries to backpropagate on that.

# What should it do?
# If we have no conditions then we don't need HMC
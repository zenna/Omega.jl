using ZenUtils
using Omega
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle

const nimages = 100
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

"Bayesian Multi Layer Percetron"
function mlp(; n = 10, alg = HMCFAST, randkargs...)
  @grab net = ciid(net_; T=Flux.Chain)
  prediction = net(X)
  loss = pw(() -> crossentropy(prediction, Y))
  @grab sb = pw(() -> Omega.SoftBool(loss))
  # @grab error = Omega.randbool(crossentropy, sb, Y)
  nets = rand(net, sb, n; alg = alg, randkargs...)
end

# The problem is that net has no conditions,
# so HMC is asking for conditions, it gets back true effectively,
# and tries to backpropagate on that.

# What should it do?
# If we have no conditions then we don't need HMC
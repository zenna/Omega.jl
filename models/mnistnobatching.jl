using ZenUtils
using Omega
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated

const imgs = MNIST.images()
# Stack images into one large batch
const X = hcat(float.(reshape.(imgs, :))...) # |> gpu

const labels = MNIST.labels()

# One-hot-encode the labels
const Y = onehotbatch(labels, 0:9) # |> gpu

function net_(ω)
  Chain(
    Dense(ω[@id], 28^2, 32, relu),
    Dense(ω[@id], 32, 10),
    softmax)
end

"Bayesian Multi Layer Percetron"
function mlp(;n = 10, alg = HMCFAST, randkargs...)
  @grab net = ciid(net_; T=Flux.Chain)
  prediction = net(X)
  loss = pw(() -> crossentropy(prediction, Y))
  @grab sb = pw(() -> Omega.SoftBool(loss))
  # @grab error = Omega.randbool(crossentropy, sb, Y)
  nets = rand(net, sb, n; alg = alg, randkargs...)
end
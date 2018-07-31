using ZenUtils
using Omega
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle

lift(:(Omega.SoftBool), 1)
lift(:(Flux.crossentropy), 2)

"Stack images into one large batch"
function data(nimages = 3000)
  imgs = MNIST.images()[1:nimages]
  X = hcat(float.(reshape.(imgs, :))...) # |> gpu
  labels = MNIST.labels()[1:nimages]
  Y = onehotbatch(labels, 0:9) # |> gpu 
  X, Y
end

"Test Data"
function testdata()
  tX = hcat(float.(reshape.(MNIST.images(:test), :))...) |> gpu
  tY = onehotbatch(MNIST.labels(:test), 0:9) |> gpu
  tX, tY
end

"Bayesian Multi Layer Percetron"
function net_(ω)
  Chain(
    Dense(ω[@id], 28^2, 32, relu),
    Dense(ω[@id], 32, 10),
    softmax)
end

"Loss term to condition"
function loss(X, Y, net)
  prediction = net(X)
  loss = -crossentropy(prediction, Y)
  sb = SoftBool(loss)
end

"Run INference"
function infer(net, error; n = 10, alg = HMCFAST, randkwargs...)
  nets = rand(net, error, n; alg = alg, randkwargs...)
end

function main(; kwargs...)
  X, Y = data()
  net = ciid(net_; T = Flux.Chain)
  error = loss(X, Y, net)
  nets = infer(net, error; kwargs...)
end

accuracy(net, x, y) = mean(argmax(net(x)) .== argmax(y))

# nets = main()
# const tX, tY = testdata()
# accuracy(nets[end], tX, tY)
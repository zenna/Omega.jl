using ZenUtils
using Omega
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle

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

function net_(ω)
  Chain(
    Dense(ω[@id], 28^2, 32, relu),
    Dense(ω[@id], 32, 10),
    softmax)
end

lift(:(Omega.SoftBool), 1)
lift(:(Flux.crossentropy), 2)

"Bayesian Multi Layer Percetron"
function loss(net)
  prediction = net(X)
  loss = -crossentropy(prediction, Y)
  sb = Omega.SoftBool(loss)
  nets = rand(net, sb, n; alg = alg, randkargs...)
end

function infer(net, error; n = 10, alg = HMCFAST, randkargs...)
  nets = rand(net, error, n; alg = alg, randkargs...)
end

function main(;kwargs...)
  X, Y = data()
  net = ciid(net_; T=Flux.Chain)
  error = loss(net)
  nets = infer(net, error; kwargs...)
end

accuracy(net, ω, x, y) = mean(argmax(net(ω)(x)) .== argmax(y))

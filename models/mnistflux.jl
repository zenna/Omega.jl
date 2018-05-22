using Mu
using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated

imgs = MNIST.images()
# Stack images into one large batch
X = hcat(float.(reshape.(imgs, :))...) |> gpu

labels = MNIST.labels()
# One-hot-encode the labels
Y = onehotbatch(labels, 0:9) |> gpu

m = Chain(
  Dense(28^2, 32, relu),
  Dense(32, 10),
  softmax) |> gpu

function net(ω)
  Chain(
    Dense(ω[@id], 28^2, 32, relu),
    Dense(ω[@id], 32, 10),
    softmax)
end

m = iid(net)
fx = m(X);
ob = Mu.randbool(crossentropy, fx, Y)

OmegaT = Mu.SimpleOmega{Int, Array}
rand(m, ob, HMC, OmegaT=OmegaT)
## Testing
## ===========
accuracy(x, y) = mean(argmax(m(x)) .== argmax(y))

dataset = repeated((X, Y), 200)
evalcb = () -> @show(loss(X, Y))
opt = ADAM(params(m))

Flux.train!(loss, dataset, opt, cb = throttle(evalcb, 10))

accuracy(X, Y)

# Test set accuracy
tX = hcat(float.(reshape.(MNIST.images(:test), :))...) |> gpu
tY = onehotbatch(MNIST.labels(:test), 0:9) |> gpu

accuracy(tX, tY)
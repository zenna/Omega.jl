using Mu
using MNIST
using Flux

const batch_size = 128
Mu.lift(:(Flux.σ), 1)
Mu.lift(:(Flux.softmax), 1)

function σ3(x::Array)
  ones(x) ./ (ones(x) + exp.(-x))
end
Mu.lift(:σ3, 1)

"Bayesian Multi Layer Percetron"
function mlp()
  nin = MNIST.NROWS * MNIST.NCOLS
  nout = 100
  # FIXME: This should be normal(0.0, 1.0, (nin, nout)
  w1 = randarray([normal(0.0, 1.0) for i = 1:nout, j = 1:nin])
  nin = 100
  nout = 100
  w2 = randarray([normal(0.0, 1.0) for i = 1:nout, j = 1:nin])
  nin = 100
  nout = 10
  w3 = randarray([normal(0.0, 1.0) for i = 1:nout, j = 1:nin])
  function f(x)
    a = σ3(w1 * x)
    b = σ3(w2 * a)
    c = σ3(w3 * b)
    Flux.softmax(c)  
  end
end

"Infinite iterator over MNIST"
function mnistcycle(batch_size)
  train_x, _ = MNIST.traindata()
  train_x = permutedims(train_x, (3, 1, 2))
  batchgen_ = DSLearn.infinite_batches(train_x, 1, batch_size)
  batchgen = IterTools.imap(Image ∘ autograd.Variable ∘ PyTorch.torch.Tensor ∘ float, batchgen_)
end

"Train MNIST using Stochastic Gradient HMC"
function train()
  f = mlp()
  datagen = mnistcycle(batch_size)
  datasample(data, nbatch) = Array(view(data, sample(1:length(data), nbatch, replace=false)))
  datagen(nbatch) = datasample(data, nbatch)
  ygen() = f(datagen(batch_size)) == ydata
  rand((w1, w2, w2), Float64), ygen(), Mu.SGHMC)
end

## FIXME:
## Every iteration we need to do f(x) == y
## Which will produce a random variable
## Broadcasting is broken
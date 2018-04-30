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

"Infinite batch generator"
function infinite_batches(data, batch_dim, batch_size, nelems = size(data, batch_dim))
  ids = Iterators.partition(Iterators.cycle(1:nelems), batch_size)
  (slicedim(data, batch_dim, id) for id in ids)
end

"Bayesian Multi Layer Percetron"
function mlp()
  nin = MNIST.NROWS * MNIST.NCOLS
  nout = 100
  # FIXME: This should be normal(0.0, 1.0, (nin, nout)
  w1 = randarray([normal(0.0, 1.0) for i = 1:nin, j = 1:nout])
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
  f, w1, w2, w3
end

"Infinite iterator over MNIST"
function mnistcycle(batch_size)
  train_x, train_y = MNIST.traindata()
  traindata = (train_x, train_y)
  batchgen_x = infinite_batches(train_x, 2, batch_size)
  batchgen_y = infinite_batches(train_y, 1, batch_size)
  Iterators.zip(batchgen_x, batchgen_y)
end

function ygengen()
  xyiter = mnistcycle()
  state = start(xyiter)
  function ygen()
    item, state = next(xyiter, state)
    return item
  end
end

"Train MNIST using Stochastic Gradient HMC"
function train(niter)
  f, w1, w2, w3 = mlp()
  gen = mnistcycle(batch_size)
  state = start(gen)
  function ygen(state)
    item, state = next(gen, state)
    predicate = f(item[1]) == item[2]
    return predicate, state
  end
  samples = rand(randarray([w1, w2, w3]), ygen, Mu.SGHMC, state, n=niter)
end

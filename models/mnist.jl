using Mu
using MNIST
using Flux

const batch_size = 128
Mu.lift(:(Flux.σ), 1)
Mu.lift(:(Flux.softmax), 1)

σ3(x) =  ones(x) ./ (ones(x) + exp.(-x))
Mu.lift(:σ3, 1)

## Data 
## ====

"Infinite batch generator"
function infinite_batches(data, batch_dim, batch_size, nelems = size(data, batch_dim))
  ids = Iterators.partition(Iterators.cycle(1:nelems), batch_size)
  (slicedim(data, batch_dim, id) for id in ids)
end

"Infinite iterator over MNIST"
function mnistcycle(batch_size)
  train_x, train_y = MNIST.traindata()
  traindata = (train_x, train_y)
  batchgen_x = infinite_batches(train_x, 2, batch_size)
  batchgen_y = infinite_batches(train_y, 1, batch_size)
  Iterators.zip(batchgen_x, batchgen_y)
end

"Bayesian Multi Layer Percetron"
function mlp()
  nin = MNIST.NROWS * MNIST.NCOLS
  # nout = 100
  # FIXME: This should be normal(0.0, 1.0, (nin, nout)
  # w1 = randarray([normal(0.0, 1.0) for i = 1:nin, j = 1:nout])
  # nin = 100
  # nout = 20
  # w2 = randarray([normal(0.0, 1.0) for i = 1:nin, j = 1:nout])
  # nin = 20
  nout = 10
  w3 = randarray([normal(0.0, 1.0) for i = 1:nin, j = 1:nout])
  function f(x; weight3=w3)
    # a = σ3(x * weight1)
    # b = σ3(a * weight2)
    c = σ3(x * weight3)
    Flux.softmax(c)
  end
  f, w3
end

"Train MNIST using Stochastic Gradient HMC"
function train(; trainkwargs...)
  f, w3 = mlp()
  gen = mnistcycle(batch_size)
  state = start(gen)
  function ygen(state)
    item, state = next(gen, state)
    batch_x = transpose(item[1])
    batch_y = convert(Array{Int64}, Flux.onehotbatch(convert(Array{Int64}, item[2]), 0:9))
    predicate = f(batch_x) == batch_y
    return predicate, state
  end
  samples = rand(w3, ygen, state, Mu.SGHMC; trainkwargs...)
end

"Test Bayesian network for MNIST using SGHMC"
function test(; trainkwargs...)
  f, _ = mlp()
  weights = mean(train(niter; trainkwargs...))
  test_x, test_y = MNIST.testdata()
  correct = 0
  for i = 1:size(test_y)[1]
    x = transpose(test_x[:, i])
    onehot_y = f(x, weight3=weights)
    y = Flux.argmax(transpose(onehot_y))[1]
    testy = convert(Int64, test_y[i])
    if y == testy
      correct += 1
    end
  end
  accepted = correct / size(test_y)[1]
end

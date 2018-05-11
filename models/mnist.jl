using Mu
using MNIST
using Flux

# σ3(x) =  ones(x) ./ (ones(x) .+ exp.(-x))
σ3(x) =  1.0 ./ (1.0 .+ exp.(-x))
σ3(x) =  1.0 ./ (1.0 .+ exp.(-x))

const batch_size = 1280
Mu.lift(:(Flux.σ), 1)
Mu.lift(:(Flux.softmax), 1)
Mu.lift(:σ3, 1)

"Infinite batch generator"
function infinite_batches(data, batch_dim, batch_size, nelems = size(data, batch_dim))
  ids = Iterators.partition(Iterators.cycle(1:nelems), batch_size)
  (slicedim(data, batch_dim, id) for id in ids)
end

"Infinite iterator over MNIST"
function mnistcycle(batch_size)
  train_x, train_y = MNIST.traindata()
  train_x = train_x ./ 256
  train_x / 256.0
  traindata = (train_x, train_y)
  batchgen_x = infinite_batches(train_x, 2, batch_size)
  batchgen_y = infinite_batches(train_y, 1, batch_size)
  Iterators.zip(batchgen_x, batchgen_y)
end

"Bayesian Multi Layer Percetron"
function mlp()
  nin = MNIST.NROWS * MNIST.NCOLS
  nout = 10
  w3 = logistic(0.0, 0.01, (nout, nin))
  # w3 = uniform(-0.5, 0.5, (nout, nin))
  function f(x; weight3=w3)
    eps = 1e-6
    c = σ3(weight3 * x)
    Flux.softmax(c) + eps
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
    batch_x = item[1]
    batch_y = float(Flux.onehotbatch(item[2], 0:9))
    predicate = f(batch_x) == batch_y 
    predicate = Mu.randbool(Flux.crossentropy, f(batch_x), batch_y)
    # predicate = Mu.randbool(Flux.binarycrossentropy, f(batch_x), batch_y)
    return predicate, state
  end
  OmegaT = Mu.SimpleOmega{Int, Array}
  # OmegaT = Mu.SimpleOmega{Int, Flux.TrackedArray}
  samples = rand(w3, ygen, state, SGHMC; OmegaT=OmegaT, trainkwargs...)
  # samples = w3(OmegaT())
  # @grab samples
  weights = samples
  # @grab weights
  samples
end

"Test Bayesian network for MNIST using SGHMC"
function test(; trainkwargs...)
  weights = train(; trainkwargs...)[end]
  # weights = weights_grab
  f, _ = mlp()
  test_x, test_y = MNIST.testdata()
  correct = 0
  for i = 1:size(test_y)[1]
    x = test_x[:, i]
    onehot_y = f(x, weight3=weights)
    y = Flux.argmax(onehot_y) - 1
    testy = convert(Int64, test_y[i])
    # testy
    if y == testy
      correct += 1
    end
  end
  @show accepted = correct / size(test_y)[1]
end

test(; n=500, nsteps=10, stepsize=0.001)

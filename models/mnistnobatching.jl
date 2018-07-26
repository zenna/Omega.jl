using Omega
using MNIST
using Flux

σ3(x) =  1.0 ./ (1.0 .+ exp.(-x))
const train_x, train_y = MNIST.traindata()

Omega.lift(:(Flux.σ), 1)
Omega.lift(:(Flux.softmax), 1)
Omega.lift(:σ3, 1)

"Bayesian Multi Layer Percetron"
function mlp(;n = 10, alg = HMCFAST, ΩT = Omega.SimpleΩ{Int, Array}, randkargs...)
  nin = MNIST.NROWS * MNIST.NCOLS
  nout = 10
  net = ciid(Dense, nin, nout, σ3)
  prediction = net(train_x)
  error = prediction == train_y
  nets = rand(net, error; randkargs...)
end
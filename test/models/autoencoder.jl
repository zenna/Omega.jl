import Mu: softeq
using PyTorch
using PyCall
using ProgressMeter
using UnicodePlots
invraytrace__file = joinpath(Pkg.dir("Mu"), "test", "benchmarks", "invraytrace.jl")
include(invraytrace__file)

# from https://github.com/L1aoXingyu/pytorch-beginner/blob/master/08-AutoEncoder/conv_autoencoder.py
variable(x::Array) = PyTorch.autograd.Variable(PyTorch.torch.Tensor(x))

@pydef type Autoencoder <: nn.Module
  __init__(self,
           nlatent = 30,
           act = nn.ReLU) = begin
      pybuiltin(:super)(Autoencoder, self)[:__init__]()
      self[:nlatent] = nlatent
      # convs = [(32, 8, [1,4,4,1]), (64, 4, [1,2,2,1]), (64, 3, [1,1,1,1])]
      self[:encoder_cnn] = nn.Sequential(
          nn.Conv2d(3, 32, 8, stride=4, padding=2),  # b, 16, 10, 10 #output = 25x25x32
          nn.ReLU(true),
          nn.BatchNorm2d(32),
          #nn.MaxPool2d(2, stride=2, return_indices=true),  # b, 16, 5, 5 # 18x18x16
          nn.Conv2d(32, 64, 4, stride=3, padding=0),  # b, 8, 3, 3  8x8x64
          nn.ReLU(true),
          nn.Conv2d(64, 64, 4, stride=2, padding=0),  # b, 8, 3, 3  3x3x64
          #nn.MaxPool2d(2, stride=1, return_indices=true)  # b, 8, 2, 2  # 8x8x1
      )
      self[:decoder_cnn] = nn.Sequential(
          #nn.MaxUnpool2d(2, stride=1), # 9x9x1
          nn.ConvTranspose2d(64, 64, 4, stride=2, padding=0),  # b, 16, 5, 5 
          nn.ReLU(true),
          #nn.MaxUnpool2d(2, stride=2), # 9x9x1
          nn.ConvTranspose2d(64, 32, 4, stride=3, padding=0),  # b, 8, 15, 15
          nn.ReLU(true),
          nn.ConvTranspose2d(32, 3, 8, stride=4, padding=2),  # b, 1, 28, 28
          nn.Sigmoid()
      )
      self[:encoder_fc] = nn.Sequential(
        nn.Linear(3*3*64, self[:nlatent]),
        nn.ReLU(true)
      )
      self[:decoder_fc] = nn.Sequential(
        nn.Linear(self[:nlatent], 3*3*64),
        nn.ReLU(true)
      )
    end

  encoder(self, x) = begin
    x = self[:encoder_cnn](x)
    x = x[:view](-1, 3*3*64)
    self[:encoder_fc](x)
  end

  decoder(self, x) = begin
    x = self[:decoder_fc](x)
    x = x[:view](-1, 64, 3, 3)
    self[:decoder_cnn](x)
  end

  forward(self, x) = begin
      x = self[:encoder](x)
      x = self[:decoder](x)
  end
end

function criterion(pred, gt)
  eps = 1.0e-10
  partial = gt * pred[:add](eps)[:log]() + gt[:neg]()[:add](1.0) * pred[:add](eps)[:neg]()[:add](1.0)[:log]()
  partial[:neg]()[:sum]()
end

function to_batched(data::Vector)
  data = map(x->x.img, data)
  imgs = permutedims(cat(4, data...), [4, 3, 1, 2]);
  imgs/255.0
end

function to_torch(data::Vector)
  data |> to_batched |> variable
end

function from_torch(data)
  floats = data[:data][:numpy]()
  permutedims(floats, [1, 3, 4, 2]) * 255
end

function generate_train_set(img, target, N=1000-1)
  imgs = [rand(img) for i in 1:N];
  push!(imgs, img_obs);
  imgs
end

function optimizer()
  optimizer = optim.Adam(model[:parameters](), lr=0.001, weight_decay=1e-5)
end

function train_network!(model, imgs, num_epochs = 200, batch_size = 40)
  imgs_batched = imgs |> to_batched;
  for epoch in 1:num_epochs
    permutation = randperm(size(imgs)[1]);
    l = 0.0
    for part in Iterators.partition(permutation, batch_size)
      im = variable(imgs_batched[part, :, :, :]);
      output = model(im);
      loss = criterion(output, im)
      optimizer[:zero_grad]();
      loss[:backward]();
      optimizer[:step]();
      l = loss[:data][:numpy]()[1]
    end
    println("epoch $epoch/$num_epochs, loss:$(l)");
  end
  model
end

## XXX This is nasty. we need to train/store the model somewhere
## But it needs to be accesible to `softeq`
## It could be even better to cache the latent values for `y`
imgs = generate_train_set(img, img_obs)
global model = train_network!(Autoencoder(), imgs)
encoder(model, temp=1.0) = (x)->model[:encoder]([x,] |>to_torch)[:data][:numpy]()/temp
encoder_ = encoder(model)

function softeq(img_x::Img, img_y::Img)
  x = img_x.img |> encoder_
  y = img_y.img |> encoder_
  Mu.LogSoftBool(-(x - y).^2 |> sum)
end

samples = rand(img, img == img_obs, SSMH)
samples[end] |> img |> rgbimg |> imshow

function plot_learning(samples)
  z_obs = encoder_(img_obs);
  z(rng) = rng |> img |> encoder_
  distances = (rng-> -(z_obs - z(rng)).^2 |> sum).(samples);
  lineplot(distances)
end

function train()
  φ = params()
  imgs = generate_train_set(img, img_obs, φ[:nimages])
  autoencoder = Autoencoder(nlatent = φ[:nlatent])
  model = train_network!(autoencoder, imgs, φ[:num_epochs], φ[:batch_size])
  encoder(model, temp=1.0) = (x)->model[:encoder]([x,] |>to_torch)[:data][:numpy]()/temp
  encoder_ = encoder(model)
  samples = rand(img, img == img_obs, SSMH)
end

function netparams()
  φ = Params()
  φ[:act] = uniform([nn.Relu, nn.Elu])
  φ[:nlatent] = uniform([30, 40, 50])
end

function optim_parmas()
  φ[:optimizer] = uniform([nn.ADAM, nn.RMSPROP])
  lr = uniform([0.0001, 0.001, 0.01, 0.1])
  alg_args(::Type{nn.ADAM}) = Params(:lr => lr, :weight_decay =>1e-5)
  φ[:optimizer_args] = alg_args(uniform([nn.ADAM]))
end

function params()
  φ = Params()
  φ[:nimages] = 1000-1
  φ[:num_epochs] = uniform([200, 400])
  φ[:batch_size] = 40
  φ[:netparams] = netparams()
end
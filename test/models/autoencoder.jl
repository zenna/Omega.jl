using PyTorch
using PyCall
using ProgressMeter
using UnicodePlots
invraytrace__file = joinpath(Pkg.dir("Mu"), "test", "benchmarks", "invraytrace.jl")
include(invraytrace__file)


# from https://github.com/L1aoXingyu/pytorch-beginner/blob/master/08-AutoEncoder/conv_autoencoder.py


variable(x::Array) = PyTorch.autograd.Variable(PyTorch.torch.Tensor(x))

@pydef type Autoencoder <: nn.Module
  __init__(self) = begin
      pybuiltin(:super)(Autoencoder, self)[:__init__]()
      # convs = [(32, 8, [1,4,4,1]), (64, 4, [1,2,2,1]), (64, 3, [1,1,1,1])]
      self[:encoder] = nn.Sequential(
          nn.Conv2d(3, 32, 8, stride=4, padding=2),  # b, 16, 10, 10 #output = 25x25x32
          nn.ReLU(true),
          nn.BatchNorm2d(32),
          #nn.MaxPool2d(2, stride=2, return_indices=true),  # b, 16, 5, 5 # 18x18x16
          nn.Conv2d(32, 64, 4, stride=3, padding=0),  # b, 8, 3, 3  8x8x64
          nn.ReLU(true),
          nn.Conv2d(64, 5, 4, stride=2, padding=0),  # b, 8, 3, 3  3x3x5
          #nn.MaxPool2d(2, stride=1, return_indices=true)  # b, 8, 2, 2  # 8x8x1
      )
      self[:decoder] = nn.Sequential(
          #nn.MaxUnpool2d(2, stride=1), # 9x9x1
          nn.ConvTranspose2d(5, 64, 4, stride=2, padding=0),  # b, 16, 5, 5 
          nn.ReLU(true),
          #nn.MaxUnpool2d(2, stride=2), # 9x9x1
          nn.ConvTranspose2d(64, 32, 4, stride=3, padding=0),  # b, 8, 15, 15
          #nn.ReLU(true),
          nn.ConvTranspose2d(32, 3, 8, stride=4, padding=2),  # b, 1, 28, 28
          nn.Sigmoid()
      )
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
  imgs = permutedims(cat(4, data...), [4, 3, 1, 2]);
  imgs/255.0
end

function to_torch(data::Vector)
  data |> to_batched |> variable
end

function generate_train_set(img, target, N=1000-1)
  imgs = [rand(img) for i in 1:N];
  push!(imgs, img_obs);
  imgs
end

function train_network(model, imgs, num_epochs = 200, batch_size = 40)
  optimizer = optim.Adam(model[:parameters](), lr=0.001,
                             weight_decay=1e-5)
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

# prediction = model(variable(imgs))
# prediction = prediction[:data][:numpy]();
# prediction = prediction*255;
# prediction2 = permutedims(prediction, [1, 3, 4, 2]);
# imshow(rgbimg(prediction2[1, :,:,:]))




"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(x::Mu.RandVar{T}, target_img,
                   encoder;
                   n::Integer = 1000,
                   OmegaT::OT = Mu.DefaultOmega, 
                   ω = OmegaT()) where {T, OT}
  target = encoder(target_img)
  distance(x) = -((x - target) .^2 |> sum)
  last =  ω |> x |>  encoder |> distance
  qlast = 1.0
  samples = []
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      Mu.update_random(ω)
    end
    p_ = ω_ |> x |>  encoder |> distance
    ratio = p_ - last
    if (rand() |> log) < ratio
      ω = ω_
      last = p_
      accepted += 1.0
    end
    push!(samples, ω)
  end
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(n))\n")
  samples
end




imgs = generate_train_set(img, img_obs)
model = train_network(Autoencoder(), imgs)
encoder(model, temp=1.0) = (x)->model[:encoder]([x,] |>to_torch)[:data][:numpy]()/temp

samples = rand(img, 
                img_obs,
                encoder(model),
                n=10000);

encoder_ = encoder(model)
z_obs = encoder_(img_obs);
distances = (rng-> -(z_obs - encoder_(img(rng))).^2 |> sum).(samples[end-500:end]);
lineplot(distances)

samples2 = rand(img, 
                img_obs,
                encoder(model, 0.5),
                n=10000,
                ω=samples[end]);


function random_projection()
# random projection                
  rand_proj_mat = randn(50, 100*100*3);
  encoder(proj) = (x)->proj * reshape(x, 100*100*3, 1)

  encoder_ = encoder(rand_proj_mat) 
  samples = rand(img, 
                  img_obs,
                  encoder_,
                  n=4000);

  z_obs = encoder_(img_obs);

  distances = [-(z_obs - encoder_(img(rng))).^2 |> sum for rng in samples];
  samples
end

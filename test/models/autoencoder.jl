using PyTorch
using PyCall
using ProgressMeter
using UnicodePlots


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


model = Autoencoder()

function criterion2(pred, gt)
  eps = 1.0e-10
  partial = gt * pred[:add](eps)[:log]() + gt[:neg]()[:add](1.0) * pred[:add](eps)[:neg]()[:add](1.0)[:log]()
  partial[:neg]()[:sum]()
end
#criterion = nn.MSELoss()
optimizer = optim.Adam(model[:parameters](), lr=0.001,
                             weight_decay=1e-5)

function to_batched(data::Vector)
  imgs = permutedims(cat(4, data...), [4, 3, 1, 2]);
  imgs/255.0
end

function to_torch(data::Vector)
  data |> to_batched |> variable
end

N = 1000-1

imgs = [rand(img) for i in 1:N];
push!(imgs, img_obs);
imgs_batched = imgs |> to_batched;
batch_size = 40;
num_epochs = 200;

for epoch in 1:num_epochs
  permutation = randperm(size(imgs)[1]);
  l = 0.0
  for part in Iterators.partition(permutation, batch_size)
    im = variable(imgs_batched[part, :, :, :]);
    output = model(im);
    loss = criterion2(output, im)
    optimizer[:zero_grad]();
    loss[:backward]();
    optimizer[:step]();
    l = loss[:data][:numpy]()[1]
  end
  println("epoch $epoch/$num_epochs, loss:$(l)");
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
                   OmegaT::OT = Mu.DefaultOmega) where {T, OT}
  ω = OmegaT()
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
      plast = p_
      accepted += 1.0
    end
    push!(samples, ω)
  end
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(n))\n")
  samples
end


samples = rand(img, 
                img_obs,
                (x) -> model[:encoder]([x,] |>to_torch)[:data][:numpy](),
                n=40000);






# random projection                
rand_proj_mat = randn(50, 100*100*3);


encoder(x) = rand_proj_mat * reshape(x, 100*100*3, 1)

samples = rand(img, 
                img_obs,
                encoder,
                n=40000);

z_obs = encoder(img_obs)

distances = [(z_obs - encoder(img(rng))).^2 |> sum for rng in samples];
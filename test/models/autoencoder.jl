using PyTorch
using PyCall


# from https://github.com/L1aoXingyu/pytorch-beginner/blob/master/08-AutoEncoder/conv_autoencoder.py


variable(x::Array) = PyTorch.autograd.Variable(PyTorch.torch.Tensor(x))

@pydef type Autoencoder <: nn.Module
  __init__(self) = begin
      pybuiltin(:super)(Autoencoder, self)[:__init__]()
      self[:encoder] = nn.Sequential(
          nn.Conv2d(3, 16, 3, stride=3, padding=1),  # b, 16, 10, 10 #output = 34x34x16
          nn.ReLU(true),
          #nn.MaxPool2d(2, stride=2, return_indices=true),  # b, 16, 5, 5 # 18x18x16
          nn.Conv2d(16, 1, 2, stride=2, padding=1),  # b, 8, 3, 3  18x18x1
          nn.ReLU(true),
          #nn.MaxPool2d(2, stride=1, return_indices=true)  # b, 8, 2, 2  # 8x8x1
      )
      self[:decoder] = nn.Sequential(
          #nn.MaxUnpool2d(2, stride=1), # 9x9x1
          nn.ConvTranspose2d(1, 16, 2, stride=2, padding=1),  # b, 16, 5, 5 
          nn.ReLU(true),
          #nn.MaxUnpool2d(2, stride=2), # 9x9x1
          nn.ConvTranspose2d(16, 3, 3, stride=3, padding=1),  # b, 8, 15, 15
          #nn.ReLU(true),
          #nn.ConvTranspose2d(8, 3, 2, stride=2, padding=1),  # b, 1, 28, 28
          nn.Sigmoid()
      )
    end

  forward(self, x) = begin
        x = self[:encoder](x)
        x = self[:decoder](x)
    end
  end


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

function example_spheres()
  RayTrace.ListScene(
    [FancySphere(Vec3([0.0,      0, -20]),     4.0, Vec3([1.00, 0.32, 0.36]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([5.0,     -1, -15]),     2.0, Vec3([0.90, 0.76, 0.46]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([5.0,      0, -25]),     3.0, Vec3([0.65, 0.77, 0.97]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([-5.5,      0, -15]),    3.0, Vec3([0.90, 0.90, 0.90]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    # light (emission > 0)
    FancySphere(Vec3([0.0,     20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))])
end

img_obs = render(example_spheres());

N = 1000-1

imgs = [rand(img) for i in 1:N];
push!(imgs, img_obs);
imgs = permutedims(cat(4, imgs...), [4, 3, 1, 2]);
imgs = imgs/255.0;
batch_size = 40;
num_epochs = 200;

for epoch in 1:num_epochs
  permutation = randperm(size(imgs)[1]);
  l = 0.0
  for part in Iterators.partition(permutation, batch_size)
    im = variable(imgs[part, :, :, :]);
    output = model(im);
    loss = criterion2(output, im)
    optimizer[:zero_grad]();
    loss[:backward]();
    optimizer[:step]();
    l = loss[:data][:numpy]()[1]
  end
  println("epoch $epoch/$num_epochs, loss:$(l)");
end

function to_batched(data::Vector)
  imgs = permutedims(cat(4, data...), [4, 3, 1, 2]);
  imgs = imgs/255.0
end

function to_torch(data::Vector)
  data |> to_torch |> variable
end

prediction = model(variable(imgs))
prediction = prediction[:data][:numpy]();
prediction = prediction*255;
prediction2 = permutedims(prediction, [1, 3, 4, 2]);
imshow(rgbimg(prediction2[1, :,:,:]))

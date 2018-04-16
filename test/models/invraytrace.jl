using Mu
using ImageView
import RayTrace: SimpleSphere, ListScene, render, rgbimg
import RayTrace: FancySphere, Vec3

Mu.lift(:(RayTrace.SimpleSphere), n=2)
Mu.lift(:(RayTrace.ListScene), n=1)
Mu.lift(:(RayTrace.render), n=1)

nspheres = poisson(3)

"Randm Variable over scenes"
function scene_(ω)
  spheres = map(1:nspheres(ω)) do i
    FancySphere([uniform(ω, -6.0, 5.0), uniform(ω, -1.0, 0.0), uniform(ω, -25.0, -15.0)],
                 uniform(ω, 1.0, 4.0),
                 [uniform(ω, 0.0, 1.0), uniform(ω, 0.0, 1.0), uniform(ω, 0.0, 10.0)],
                 1.0,
                 0.0,
                 Vec3([0.0, 0.0, 0.0]))
  end
  light = FancySphere(Vec3([0.0, 20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))
  typeof(spheres)
  push!(spheres, light)
  scene = ListScene(spheres)
end

scene = iid(scene_)     # Random Variable of scenes
img = render(scene)     # Random Variable over images
img_ = rand(img)

## Show a random image
showscene(scene) = imshow(rgbimg(render(scene)))
rgbimg_ = rgbimg(img_)
imshow(rgbimg_)

# img_obs = rand(img)   # arbitrary observed image

"Some example spheres which should create actual image"
function example_spheres()
  RayTrace.ListScene(
   [FancySphere(Vec3([0.0,      0, -20]),     4.0, Vec3([1.00, 0.32, 0.36]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([5.0,     -1, -15]),     2.0, Vec3([0.90, 0.76, 0.46]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([5.0,      0, -25]),     3.0, Vec3([0.65, 0.77, 0.97]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    FancySphere(Vec3([-5.5,      0, -15]),    3.0, Vec3([0.90, 0.90, 0.90]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
    # light (emission > 0)
    FancySphere(Vec3([0.0,     20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))])
end

img_obs = render(example_spheres())

scene_posterior = rand(scene, img == img_obs)

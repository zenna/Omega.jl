u sing Mu
using ImageView
import RayTrace: SimpleSphere, ListScene, render, rgbimg

Mu.lift(:(RayTrace.SimpleSphere), n=2)
Mu.lift(:(RayTrace.ListScene), n=1)
Mu.lift(:(RayTrace.render), n=1)

nspheres = poisson(3)

"Randm Variable over scenes"
function scene_(ω)
  xyz = [uniform(ω, -20.0, 20.0), uniform(ω, -1.0, 1.0), uniform(ω, -20.0, 20.0)]
  spheres = [RayTrace.SimpleSphere(xyz, uniform(ω, 0.0, 5.0)) for i = 1:nspheres(ω)]
  scene = ListScene(spheres)
end

scene = iid(scene_)     # Random Variable of scenes
img = render(scene)     # Random Variable over images

# img_obs = rand(img)   # arbitrary observed image
img_obs = RayTrace.render(RayTrace.example_scene())

scene_posterior = rand(scene, img == img_obs)
using Mu
using ImageView
using Colors
import RayTrace: SimpleSphere, ListScene, render

Mu.lift(:(RayTrace.SimpleSphere), n=2)
Mu.lift(:(RayTrace.ListScene), n=1)
Mu.lift(:(RayTrace.render), n=1)
img_obs = RayTrace.render(RayTrace.exmaple_scene())

"Create an rgb image from a 3D matrix (w, h, c)"
function rgbimg(img)
  w = size(img)[1]
  h = size(img)[2]
  clrimg = Array{Colors.RGB}(w, h)
  for i = 1:w
    for j = 1:h
      clrimg[i,j] = Colors.RGB(img[i,j,:]...)
    end
  end
  clrimg
end

# nspheres = Mu.poisson(4)
nspheres = Mu.poisson(3)
nspheres = 3
xyz = randarray([uniform(-20, 20), uniform(-1, 1), uniform(-20, 20)])
spheres = randarray([RayTrace.SimpleSphere(xyz, uniform(0,5)) for i = 1:nspheres])
scene = ListScene(spheres)
img = render(scene)

using ImageView

sphere_posterior = rand((spheres, n), img == obs_img)
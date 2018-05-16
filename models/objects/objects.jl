using Mu
using ImageView
import RayTrace: SimpleSphere, ListScene, rgbimg
import RayTrace: FancySphere, Vec3, Sphere, Scene

struct Img
  img::Array{Float64,3}
end

render(x) = Img(RayTrace.render(x))
rgbimg(x::Img) = rgbimg(x.img)

Mu.lift(:(RayTrace.SimpleSphere), n=2)
Mu.lift(:(RayTrace.ListScene), n=1)
Mu.lift(:(render), n=1)

nspheres = poisson(3)

"Randm Variable over scenes"
function scene_(ω)
  # spheres = map(1:nspheres(ω)) do i
  spheres = map(1:4) do i
    FancySphere([uniform(ω[@id][i], -6.0, 5.0), uniform(ω[@id][i] , -1.0, 0.0), uniform(ω[@id][i]  , -25.0, -15.0)],
                 uniform(ω[@id][i]  , 1.0, 4.0),
                 [uniform(ω[@id][i] , 0.0, 1.0), uniform(ω[@id][i] , 0.0, 1.0), uniform(ω[@id][i] , 0.0, 1.0)],
                 1.0,
                 0.0,
                 Vec3([0.0, 0.0, 0.0]))
  end
  light = FancySphere(Vec3([0.0, 20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))
  # push!(spheres, light)  
  scene = ListScene([spheres; light])
end

## Show a random image
showscene(scene) = imshow(rgbimg(render(scene)))

# img_obs = render(example_spheres())
function compute_posterior()
  rand(scene, img == img_obs, HMC,
                       n=1, OmegaT = Mu.SimpleOmega{Int, Float64},
                       nsteps=1)
end

## Conditions
## ==========
using ZenUtils
function same(xs)

  a = [x1 ≊ x2 for x1 in xs, x2 in xs if x1 !== x2]
  all(a)
end
norma(x) = sum(x .* x)

"Euclidean distance between all objects"
d(s1::Sphere, s2::Sphere) = norma(s1.center - s2.center)

"Distance between surfance color"
cold(s1::Sphere, s2::Sphere) = norma(s1.surface_color - s2.surface_color)

"Pairwise function on all objects"
pairwisef(f, sc::Scene) = [f(obj1, obj2) for obj1 in sc.geoms, obj2 in sc.geoms if obj1 !== obj2]

"Does sphere1 intersect with sphere2?"
intersect(s1::Sphere, s2::Sphere) = d(s1, s2) ⪅ (s1.radius + s2.radius)
nointersect(s1::Sphere, s2::Sphere) = d(s1, s2) ⪆ (s1.radius + s2.radius)

"Do any objects in the scene intersect with any other"
intersect(sc::Scene) = any(pairwisef(intersects, sc))
nointersect(sc::Scene) = all(pairwisef(nointersect, sc))
lift(:nointersect, 1)

"Are all objects isequidistant?"
isequidistant(sc::Scene) = same(pairwisef(d, sc))
lift(:isequidistant, 1)

"Distinguished in colour"
distinguishedcolor(sc::Sphere) = same(pairwisef(cold, sc))

function main()
  scene = iid(scene_)     # Random Variable of scenes
  img = render(scene)     # Random Variable over images
  # img_ = rand(img)
  samples = rand(scene, isequidistant(scene), HMC)
end
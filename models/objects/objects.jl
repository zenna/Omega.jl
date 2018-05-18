using Mu
using ImageView
using RunTools
import RayTrace: SimpleSphere, ListScene, rgbimg
import RayTrace: FancySphere, Vec3, Sphere, Scene
using BSON
using FileIO
using DataFrames


include("net.jl")

struct Img{T}
  img::T
end

render(x) = Img(RayTrace.render(x, 100, 100))
rgbimg(x::Img) = rgbimg(x.img)

Mu.lift(:(RayTrace.SimpleSphere), n=2)
Mu.lift(:(RayTrace.ListScene), n=1)
Mu.lift(:(render), n=1)

nspheres = poisson(3)

"Randm Variable over scenes"
function scene_(ω)
  # spheres = map(1:nspheres(ω)) do i
  spheres = map(1:5) do i
    FancySphere([uniform(ω[@id][i], -6.0, 5.0), uniform(ω[@id][i] , -6.0, 0.0), uniform(ω[@id][i]  , -25.0, -15.0)],
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


function scenetodf(scene::RayTrace.ListScene)
  alldf = DataFrame(x = Float64[], y = Float64[], z = Float64[], r = Float64[])
  for obj in scene.geoms
    x, y, z = obj.center
    df_ = DataFrame(x = [x], y = [y], z = [z], r = [obj.radius])
    append!(alldf, df_)
  end
  alldf
end

# "Randm Variable over scenes"
# function scene_(ω)
#   # spheres = map(1:nspheres(ω)) do i
#   spheres = map(1:10) do i
    
#     FancySphere(uniform(ω[@id][i], 0.0, 1.0, (3,)),
#                  0.5,
#                  uniform(ω[@id][i], 0.0, 1.0, (3,)),
#                  1.0,
#                  0.0,
#                  Vec3([0.0, 0.0, 0.0]))
#   end
#   light = FancySphere(Vec3([0.0, 20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))
#   # push!(spheres, light)  
#   scene = ListScene([spheres; light])
# end

"Show a random image"
showscene(scene) = imshow(rgbimg(render(scene)))

## Conditions
## ==========
function same(xs)
  a = [@show x1 ≊ x2 for x1 in xs, x2 in xs if x1 !== x2]
  @show length(xs)
  aba = all(a)
  @show aba
  println()
  aba
end
norma(x) = sqrt(sum(x .* x))

pairwisef(f, sc::Scene) = [f(obj1, obj2) for obj1 in sc.geoms, obj2 in sc.geoms if obj1 !== obj2]

"Euclidean distance between all objects"
d(s1::Sphere, s2::Sphere) = norma(s1.center - s2.center)

"Distance between surfance color"
cold(s1::Sphere, s2::Sphere) = norma(s1.surface_color - s2.surface_color)

intersect(s1::Sphere, s2::Sphere) = d(s1, s2) ⪅ (s1.radius + s2.radius)
function nointersect(s1::Sphere, s2::Sphere)
  d1 = d(s1, s2)
  d2 = (s1.radius + s2.radius)
  # d1 > d2
  d1 ⪆ (d2 + 0.5)
end

"Do any objects in the scene intersect with any other"
intersect(sc::Scene) = any(pairwisef(intersects, sc))
nointersect(sc::Scene) = all(pairwisef(nointersect, sc))
lift(:nointersect, 1)

"Are all objects isequidistant?"
isequidistant(sc::Scene) = same(pairwisef(d, sc))
lift(:isequidistant, 1)

"Distinguished in colour"
distinguishedcolor(sc::Sphere) = same(pairwisef(cold, sc))

## Observation
## ===========
"Some example spheres which should create actual image"
function observation_spheres()
  scene = [FancySphere(Float64[0.0, -10004, -20], 10000.0, Float64[0.20, 0.20, 0.20], 0.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[0.0,      0, -20],     4.0, Float64[1.00, 0.32, 0.36], 1.0, 0.5, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[5.0,     -1, -15],     2.0, Float64[0.90, 0.76, 0.46], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[5.0,      0, -25],     3.0, Float64[0.65, 0.77, 0.97], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           FancySphere(Float64[-5.5,      0, -15],    3.0, Float64[0.90, 0.90, 0.90], 1.0, 0.0, Float64[0.0, 0.0, 0.0]),
           # light (emission > 0)
           FancySphere(Float64[0.0,     20.0, -30],  3.0, Float64[0.00, 0.00, 0.00], 0.0, 0.0, Float64[3.0, 3.0, 3.0])]
  RayTrace.ListScene(scene)
end

const img_obs = render(observation_spheres())

eucl(x, y) = sqrt(sum((x - y) .^ 2))

#rand_proj_mat = randn(50, 224×224×3);
δ = 5e-4
rand_proj_mat = δ*rand(sqrt(3)*[1, -1, 0, 0, 0, 0], (100,100*100*3));
encode(x) =  (rand_proj_mat*reshape(x.img, 100*100*3, 1))[:, 1]

function Mu.d(x::Img, y::Img)
  xfeatures = encode(x)
  yfeatures = encode(y)
  sum((xfeatures - yfeatures) .^ 2)
end

expanddims(x) = reshape(x, size(x)..., 1)

function main()
  scene = iid(scene_)     # Random Variable of scenes
  img = render(scene)     # Random Variable over images
  # samples = rand(scene, nointersect(scene) & (img == img_obs), HMCFAST)
  samples = rand(scene, nointersect(scene) & (img == img_obs), SSMH, n=100)
  #samples = rand(scene, nointersect(scene), HMC, n=1000);
end

## Plots
## =====
Δ(a::Sphere, b::Sphere) = norm(a.center - b.center) + abs(a.radius - b.radius)
Δ(a::Scene, b::Scene) = surjection(a.geoms, b.geoms)

"distance betwee two scenes"
function hausdorff(s1, s2, Δ = Δ)
  Δm(x, S) = minimum([Δ(x, y) for y in S])
  max(maximum([Δm(e, s2) for e in s1]), maximum([Δm(e, s1) for e in s2]))
end

function plothist(truth, samples, plt = plot())
  distances = Δ.(truth, samples)
  histogram(distances)
end
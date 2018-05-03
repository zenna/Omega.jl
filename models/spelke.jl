using Mu
using UnicodePlots
using CSV
using DataFrames
using RunTools

lift(:(Base.getindex), 2)

struct Object{T}
  x::T
  y::T
  Δx::T
  Δy::T
  # label
end

"View port into scene"
struct Camera{T}
  x::T
  y::T
  Δx::T
  Δy::T
end

"Latent scene: camera and objects"
struct Scene{O, C}
  objects::Vector{O}
  camera::C
end

struct Image{O}
  objects::Vector{O}
end

"Render scene into an image"
render(scene, camera)::Image = scene

nboxes = poisson(5)

"Scene at frame t=0"
function initscene(ω)
  objects = map(1:nboxes(ω)) do i
    Object(uniform(ω[@id][i], 0.0, 1.0),
           uniform(ω[@id][i], 0.0, 1.0),
           uniform(ω[@id][i], 10.0, 300.0),
           uniform(ω[@id][i], 10.0, 400.0))
  end
  camera = Camera(uniform(ω[@id], 0.0, 1.0),
                  uniform(ω[@id], 0.0, 1.0),
                  100.0,
                  100.0)
  Scene(objects, camera)
end

"Shift an object by adding gaussian perturbation to x, y, Δx, Δy"
function move(ω, object::Object)
  Object(object.x + normal(ω[@id], 0.0, 1.0),
         object.y + normal(ω[@id], 0.0, 1.0),
         object.Δx + normal(ω[@id], 0.0, 1.0),
         object.Δy + normal(ω[@id], 0.0, 1.0))
end

"Move entire all objects in scene"
function move(ω, scene::Scene)
  Scene(map(iobj -> move(ω[iobj[1]], iobj[2]), enumerate(scene.objects)), scene.camera)
end

"Simulate `nsteps`"
function video_(ω, nsteps = 1000)
  scene = initscene(ω)
  trajectories = Scene[]
  for i = 1:nsteps
    scene = move(ω[i], scene)
    push!(trajectories, scene)
  end
  trajectories
end

## Inference
## =========

"Construct a scene from dataset"
function Scene(df::AbstractDataFrame)
  objects = map(eachrow(df)) do row
    x = row[:y]
    dx = row[:dy]
    Δx = dx - x
    y = row[:x]
    dy = row[:dx]
    Δy = dy - y
    Object(float(x), float(y), float(Δx), float(Δy))
  end
  camera = Camera(0.0, 0.0, 640.0, 360.0)
  Scene(objects, camera)
end

Δ(a::Real, b::Real) = sqrt((a - b)^2)
Δ(a::Object, b::Object) =
  mean([Δ(a.x, b.x), Δ(a.y, b.y), Δ(a.Δx, b.Δx), Δ(a.Δy, b.Δy)])
Δ(a::Scene, b::Scene) = hausdorff(a.objects, b.objects)

"Distance betwee two scenes"
function hausdorff(s1, s2, Δ = Δ)
  Δm(x, S) = minimum([Δ(x, y) for y in S])
  max(maximum([Δm(e, s2) for e in s1]), maximum([Δm(e, s1) for e in s2]))
end

function Mu.softeq(a::Array{<:Scene,1}, b::Array{<:Scene})
  dists = Δ.(a, b)
  d = mean(dists)
  e = log(1 - Mu.f2(d, a = 0.138))
  Mu.LogSoftBool(e)
end

## Visualization
## =============
"Four points (x, y) - corners of `box`"
function corners(box)
  ((box.x, box.y),
   (box.x + box.Δx, box.y),
   (box.x + box.Δx, box.y + box.Δy),
   (box.x, box.y + box.Δy))
end

"Draw Box"
function draw(obj, canvas, color = :blue)
  corners_ = corners(obj)
  for i = 1:length(corners_)
    p1 = corners_[i]
    p2 = i < length(corners_) ? corners_[i + 1] : corners_[1]
    lines!(canvas, p1..., p2..., color)
  end
  canvas
end

"Fix aspect ratio (account that uncicode is taller than wide)"
fixao(x, y; aspectratio = 0.5) = (x, Int(y * aspectratio))

"Draw Scene"
function draw(scene::Scene,
              canvas = BrailleCanvas(fixao(64, 32)..., origin_x = 0., origin_y = 0.,
                                     width = scene.camera.Δx, height = scene.camera.Δy))
  draw(scene.camera, canvas, :red)
  foreach(obj -> draw(obj, canvas, :blue), scene.objects)
  canvas
end

"Draw a sequence of frames"
function viz(vid, sleeptime = 0.2)
  foreach(vid) do o
    display(draw(o))
    sleep(sleeptime)
  end
end

## Run
## ===
datapath = joinpath(datadir(), "spelke", "TwoBalls", "TwoBalls_DetectedObjects.csv")
data = CSV.read(datapath)
nframes = maximum(data[:frame]) - minimum(data[:frame])
nframes = length(unique())
frames = groupby(data, :frame)
video = iid(ω -> video_(ω, nframes))
rand(video)
realvideo = map(Scene, frames)
samples = rand(video, video == realvideo, SSMH);

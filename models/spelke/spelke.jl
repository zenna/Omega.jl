using Mu
using UnicodePlots
using CSV
using DataFrames
using RunTools
using ArgParse
using Stats

include("distances.jl")

lift(:(Base.getindex), 2)
const Δxk = :x2
const Δyk = :y2

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

nboxes = poisson(5) + 1

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
                  640.0,
                  480.0)
  Scene(objects, camera)
end

function accumprop(prop, video)
  props = Float64[]
  for scene in video, object in scene.objects
    push!(props, getfield(object, prop))
  end
  props
end 

"Scene at frame t=0"
function initscene(ω, data)
  objects = map(1:nboxes(ω)) do i
    Object(normal(ω[@id][i], mean(accumprop(:x, data)), std(accumprop(:x, data))),
           normal(ω[@id][i], mean(accumprop(:y, data)), std(accumprop(:y, data))),
           normal(ω[@id][i], mean(accumprop(:Δx, data)), std(accumprop(:Δx, data))),
           normal(ω[@id][i], mean(accumprop(:Δy, data)), std(accumprop(:Δy, data))))
  end
  camera = Camera(normal(ω[@id], 0.0, 1.0),
                  normal(ω[@id], 0.0, 1.0),
                  640.0,
                  480.0)
  Scene(objects, camera)
end


"Shift an object by adding gaussian perturbation to x, y, Δx, Δy"
function move(ω, object::Object)
  Object(object.x + normal(ω[@id], 0.0, 2.0),
         object.y + normal(ω[@id], 0.0, 2.0),
         object.Δx + normal(ω[@id], 0.0, 2.0),
         object.Δy + normal(ω[@id], 0.0, 2.0))
end

"Move entire all objects in scene"
function move(ω, scene::Scene)
  Scene(map(iobj -> move(ω[iobj[1]], iobj[2]), enumerate(scene.objects)), scene.camera)
end

"Simulate `nsteps`"
function video_(ω, scene::Scene = initscene(ω), nsteps = 1000)
  trajectories = Scene[]
  for i = 1:nsteps
    scene = move(ω[i], scene)
    push!(trajectories, scene)
  end
  trajectories
end

video_(ω, data::Vector, nsteps = 1000) = video_(ω, initscene(ω, data), nsteps)

## GP model
## ========

d(x1, x2) = x1 - x2
K(x1, x2; l=0.1) = exp(-(d(x1, x2)^2)/(2l^2))
t = 1:0.1:10
using PDMats
Σ = PDMat([K(x, y) for x in t, y in t] * 300)

"Gaussian Process Random Variable"
function gp_(ω)
  trajectories = Scene[]
  objects = map(1:nboxes(ω)) do i
    x = mvnormal(ω[@id][i][1], zeros(t), Σ)
    y = mvnormal(ω[@id][i][2], zeros(t), Σ)
    # Δx = mvnormal(ω[@id][i][3], zeros(t), Σ)
    # Δy = mvnormal(ω[@id][i][4], zeros(t), Σ)
    Δx = 30.0
    Δy = 30.0
    Object.(x, y, Δx, Δy)
    # @grab x
  end
  #@grab objects
  camera = Camera(0.0, 0.0, 640.0, 480.0)
  obj_(t) = map(obj -> obj[t], objects)
  [Scene(obj_(i), camera) for i = 1:length(t)] 
end

"Gaussian Process Prior"
function testgpprior()
  w = SimpleOmega{Int, Array}()
  gpvideo = iid(gp_)
  samples = gpvideo(w)
  viz(samples)
end

## Inference
## =========

"Construct a scene from dataset"
function Scene(df::AbstractDataFrame)
  objects = map(eachrow(df)) do row
    @show x = row[:x]
    dx = row[Δxk]
    Δx = abs(dx - x)
    y = row[:y]
    dy = row[Δyk]
    Δy = abs(dy - y)
    Object(float(x), float(y), float(Δx), float(Δy))
  end
  camera = Camera(0.0, 0.0, 640.0, 480.0)
  Scene(objects, camera)
end

Δ(a::Real, b::Real) = sqrt((a - b)^2)
Δ(a::Object, b::Object) =
  mean([Δ(a.x, b.x), Δ(a.y, b.y), Δ(a.Δx, b.Δx), Δ(a.Δy, b.Δy)])
Δ(a::Scene, b::Scene) = speedysurjection(a.objects, b.objects)

function Mu.softeq(a::Array{<:Scene,1}, b::Array{<:Scene})
  dists = Δ.(a, b)
  d = mean(dists)
  e = log(1 - Mu.kse(d, 0.138))
  Mu.LogSoftBool(e)
end

## Visualization
## =============
"Four points (x, y) - corners of `box`"
function corners(box)
  ((box.x, box.y),
   (box.x + box.Δx, box.y),
   (box.x + box.Δx, box.y - box.Δy),
   (box.x, box.y -  box.Δy))
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
              canvas = BrailleCanvas(fixao(64, 32)..., origin_x = -50.0, origin_y = -50.0,
                                     width = scene.camera.Δx + 10, height = scene.camera.Δy + 10))
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
datapath = joinpath(datadir(), "spelke", "data", "Balls_2_DivergenceA", "Balls_2_DivergenceA_DetectedObjects.csv")

function train()
  data = CSV.read(datapath)
  nframes = length(unique(data[:frame]))
  frames = groupby(data, :frame)
  realvideo = map(Scene, frames)
  video = iid(ω -> video_(ω, realvideo, nframes))
  rand(video)
  samples = rand(video, video == realvideo, SSMH, n=10000);
  viz(samples)
end

"Frame by frame differences"
function Δs(video)
  Δs = Float64[]
  for i = 1:length(video) - 1
    v1 = video[i]
    v2 = video[i + 1]
    push!(Δs,  Δ(v1, v2))
  end
  Δs
end
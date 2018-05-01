using Mu
using UnicodePlots

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

struct Scene{O, C}
  objects::Vector{O}
  camera::C
end

struct Image{O}
  objects::Vector{O}
end

function corners(box)
  ((box.x, box.y),
   (box.x + box.Δx, box.y),
   (box.x + box.Δx, box.y + box.Δy),
   (box.x, box.y + box.Δy))
end

"Render scene into an image"
render(scene, camera)::Image = scene

"Draw Box"
function draw(obj, canvas, color = :blue)
  corners_ = corners(obj)
  for i = 1:length(corners_)
    p1 = corners_[i]
    p2 = i < length(corners_) ? corners_[i + 1] : corners_[i]
    lines!(canvas, p1..., p2..., color)
  end
end

"Draw Scene"
function draw(scene::Scene,
              canvas = BrailleCanvas(100, 100, origin_x = 0., origin_y = 0., width = 100., height = 100.))
  draw(scene.camera, canvas, :red)
  foreach(obj -> draw(obj, canvas, :blue), scene.objects)
end

nboxes = poisson(5)

"Scene at frame t=0"
function initscene(ω)
  objects = map(1:nboxes(ω)) do i
    Object(uniform(ω[@id], 0.0, 1.0),
           uniform(ω[@id], 0.0, 1.0),
           uniform(ω[@id], 0.0, 1.0),
           uniform(ω[@id], 0.0, 1.0))
  end
  camera = Camera(uniform(ω[@id], 0.0, 1.0),
                  uniform(ω[@id], 0.0, 1.0),
                  100.0,
                  100.0)
  Scene(objects, camera)
end

function move(ω, object::Object)
  Object(object.x + normal(ω[@id], 0.0, 1.0),
         object.y + normal(ω[@id], 0.0, 1.0),
         object.Δx + normal(ω[@id], 0.0, 1.0),
         object.Δy + normal(ω[@id], 0.0, 1.0))
end

function move(ω, scene::Scene)
  @grab scene
  Scene(map(obj -> move(ω, obj), scene.objects), scene.camera)
end

function video_(ω, nsteps = 1000)
  scene = initscene(ω)
  trajectories = Scene[]
  for i = 1:nsteps
    scene = move(ω, scene)
    push!(trajectories, scene)
  end
  trajectories
end

video = iid(video_)
rand(video)
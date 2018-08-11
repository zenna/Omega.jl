## Prior Conditioning
## ==================
function same(xs)
  a = [x1 ≊ x2 for x1 in xs, x2 in xs if x1 !== x2]
  # @show length(xs)
  aba = all(a)
  # @show aba
  # println()
  aba
end
norma(x) = sqrt(sum(x .* x))

pairwisef(f, sc::Scene) = [f(obj1, obj2) for obj1 in sc.geoms[1:end-1], obj2 in sc.geoms[1:end-1] if obj1 !== obj2]

"Euclidean distance between all objects"
d(s1::Sphere, s2::Sphere) = norma(s1.center - s2.center)

"Distance between surfance color"
cold(s1::Sphere, s2::Sphere) = norma(s1.surface_color - s2.surface_color)

intersect(s1::Sphere, s2::Sphere) = d(s1, s2) ⪅ (s1.radius + s2.radius)
function nointersect(s1::Sphere, s2::Sphere)
  d1 = d(s1, s2)
  d2 = (s1.radius + s2.radius)
  # d1 > d2
  withkernel(Omega.kseα(10000)) do
    @show a = d1 ⪆ d2
    Omega.SoftBool(Omega.logepsilon(a))
  end
end

"Do any objects in the scene intersect with any other"
intersect(sc::Scene) = any(pairwisef(intersects, sc))
nointersect(sc::Scene) = @show all(pairwisef(nointersect, sc))
lift(:nointersect, 1)

"Are all objects isequidistant?"
isequidistant(sc::Scene) = same(pairwisef(d, sc))
lift(:isequidistant, 1)

"Distinguished in colour"
distinguishedcolor(sc::Sphere) = same(pairwisef(cold, sc))

function main()
  scene = ciid(scene_)     # Random Variable of scenes
  img = render(scene)     # Random Variable over images
  # samples = rand(scene, nointersect(scene) & (img == img_obs), HMCFAST)
  samples = rand(scene, isequidistant(scene), HMC, n=10000)
end

function main2()
  scene = ciid(scene_)     # Random Variable of scenes
  img = render(scene)     # Random Variable over images
  samples = rand(scene, nointersect(scene) & (img == img_obs), SSMH)
end

## MISC
function scenetodf(scene::RayTrace.ListScene)
  alldf = DataFrame(x = Float64[], y = Float64[], z = Float64[], r = Float64[])
  for obj in scene.geoms
    x, y, z = obj.center
    df_ = DataFrame(x = [x], y = [y], z = [z], r = [obj.radius])
    append!(alldf, df_)
  end
  alldf
end
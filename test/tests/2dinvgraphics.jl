nobjects = 3

struct Circle
  x
  y
  radii
end

circles = [Circle(uniform(width, height)) for i = 1:nobjects]

distance(c1::Circle, c2::Circle) = sqrt((c1.x - c2.x)^2 + (c1.y - c2.y)^2)

overlap(c1, c2) = distance(c1, c2) < (c1.r + c2.r)
alloverlaps = []
for c1 in circles, c2 in circles
  if ci != cj
    push!(alloverlaps, overlap(c1, c2))
  end
end

rand(circles, !any(overlap))
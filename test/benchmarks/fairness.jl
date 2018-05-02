using Mu

"A Person"
struct Person
  ismale::Float64
  height::Float64
  age::Float64
  isrich::Float64
end

ismale(p::Person) = p.ismale
height(p::Person) = p.height
age(p::Person) = p.age
isrich(p::Person) = p.isrich
σ(x) = one(x) / (one(x) + exp(-x))

# Lifts (TODO: Automate this)
# =====
lift(:ismale, 1)
lift(:height, 1)
lift(:age, 1)
lift(:isrich, 1)
Mu.lift(:Person, 4)
Mu.lift(:σ, 1)


person = Person(bernoulli(0.3),
                uniform(130.0, 180.0),
                uniform(18.0, 50.0),
                bernoulli(0.3))

woman = Person(0.0,
               uniform(130.0, 180.0),
               uniform(18.0, 50.0),
               bernoulli(0.3))

man = Person(1.0,
             uniform(130.0, 180.0),
             uniform(18.0, 50.0),
             bernoulli(0.3))


θ = [normal(0.0, 1.0) for i = 1:3]
θ_ = randarray(θ)

# Problem is is 
# "Linear Classifier"
function isrich(w, person::Person)
  σ(person(w).height * θ[1](w) + person(w).age * θ[2](w) + person(w).ismale * θ[3](w))
end
# Mu.lift(:isrich, 1)

## Classifier
## ==========
"Linear Classifier"
function isrich2(person)
  σ(height(person) * θ[1] + age(person) * θ[2] + ismale(person) * θ[3])
end

ndata = 10
xdata = [rand(person) for i = 1:ndata]
ydata = [rand([0.0, 1.0]) for i in xdata]

fairness = prob(isrich2(man) ∥ θ_) / prob(isrich(woman) ∥ θ_) < ϵ
datacond = randarray([isrich2(xdata[i]) * bernoulli(0.9) for i = 1:length(xdata)])

samples = rand(θ_, (fairness > 0) & (datacond == ydata))
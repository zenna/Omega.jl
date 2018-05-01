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

ndata = 100
fake_person_data = [rand(person) for i = 1:ndata]

θ = [normal(0.0, 1.0) for i = 1:3]
θ_ = randarray(θ)

# Problem is is 
# "Linear Classifier"
function isrich(w, person::Person)
  σ(person(w).height * θ[1](w) + person(w).age * θ[2](w) + person(w).ismale * θ[3](w))5
end
# Mu.lift(:isrich, 1)

## Classifier
## ==========
"Linear Classifier"
function isrich2(person)
  σ(height(person) * θ[1] + age(person) * θ[2] + ismale(person) * θ[3])
end

fairness = prob(isrich2(man) ∥ θ_) / prob2(isrich(woman) ∥ θ_) < ϵ

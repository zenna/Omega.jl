using Mu

"A Person"
struct Person
  ismale::Float64
  height::Float64
  age::Float64
  isrich::Float64
end

Mu.lift(:Person, 4)

person = Person(bernoulli(0.3),
                uniform(130.0, 180.0),
                uniform(18.0, 50.0),
                bernoulli(0.3))

ndata = 100
fake_person_data = [rand(person) for i = 1:ndata]

θ = [normal(0.0, 1.0) for i = 1:3]

σ(x) = logistic

"Linear Classifier"
function isrich(person::Person, θ)
  σ(person.height * θ[1] + person.age * θ[2] + person.ismale * θ[3]) > 0.5
end

Mu.lift(:isrich, 2)

man_ = iid(person)
man = cond(man_, man_.ismale)
prob_man_is_rich = prob(rcd(isrich(man), θ))

woman_ = iid(person)
woman = cond(woman_, woman_.ismale)
prob_woman_is_rich = prob(rcd(isrich(woman), θ))

prob_man_is_rich / prob_woman_is_rich  < 0.8
using Mu

"A Person"
struct Person
  ismale::Float64
  height::Float64
  age::Float64
  isrich::Float64
end

Mu.lift(:Person, 3)

person = Person(bernoulli(0.3),
                uniform(130.0, 180.0),
                uniform(18.0, 50.0),
                bernoulli(0.3))

ndata = 100
fake_person_data = [rand(person) for i = 1:ndata]

θ = [normal(0.0, 1.0) for i = 1:3]

"Linear Classifier"
function isrich(person::Person)
  person.height * θ[1] +
    person.age * θ[2] +
    person.ismale * θ[3] > 0.0
end

data_cond = [iid(person) == data for data in fake_person_data]
modelisfair = prob(rcd(cond(isrich(person), person.ismale), θ)) / 
              prob(rcd(cond(isrich(person), person.female), θ)) < 0.8

rand(θ, modelisfair & data_cond)
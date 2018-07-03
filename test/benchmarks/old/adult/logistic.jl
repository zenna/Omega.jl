using Flux
using Flux: onehotbatch, crossentropy, throttle, argmax, @epochs

include("./read_data.jl")

train_data_X, train_data_Y, test_data_X, test_data_Y = get_train_and_test()

w = size(train_data_X)[1]

m = Chain(Dense(w, 2), softmax)

loss(x,y) = crossentropy(m(x), y) + sum(vecnorm, params(m))

pred(x) = argmax(m(x))

accuracy(x,y) = mean(pred(x) .== argmax(y))

precision(x, y) = sum(pred(x) .& argmax(y)) / sum(pred(x))

recall(x, y) = sum(pred(x) .& argmax(y)) / sum(argmax(y))

f1(x,y) = 2/(1/precision(x,y)+1/recall(x,y))

# data = zip([train_data_X[i,:] for i=1:h ], train_data_Y)

opt = ADAM(params(m))

data = [(train_data_X, train_data_Y)]

evalcb = () -> @show(loss(train_data_X, train_data_Y), accuracy(train_data_X, train_data_Y))

println("Initial accuracy: $(accuracy(train_data_X, train_data_Y))")

@epochs 1000 Flux.train!(loss, data, opt, cb=throttle(evalcb,10))

println("Test accuracy: $(accuracy(test_data_X, test_data_Y))")
println("Precision: $(precision(test_data_X, test_data_Y)), Recall: $(recall(test_data_X, test_data_Y)),
        f1: $(f1(test_data_X, test_data_Y))")

using Mu
using ScikitLearn

@sk_import mixture: GaussianMixture

include("./read_data.jl")

# Read data
train_data_X, train_data_Y, test_data_X, test_data_X = get_train_and_test()

# Define the population model

mixture_data = vcat(train_data_X, train_data_Y)

mixture_data = transpose(mixture_data)

clf = GaussianMixture(n_components=2, covariance_type="full")

fit!(clf, mixture_data)

weights = Array(clf["weights_"])

means = Array(clf["means_"])

covars = Array(clf["covariances_"])

function rand_gaussian_mixture(weights, means, covars)
    cat_var = Mu.categorical(weights)
    compots = []

    for (mean, covar) in zip(means, covars)
        push!(compots, Mu.mvnormal(mean, covar))
    end

    function mixture(ω)
        cat = cat_var(ω[@id])
        comp = compots[cat]
        return comp(ω[@id])
    end
end

mixture_ = rand_gaussian_mixture(weights, means, covars)
mixture = iid(mixture_)

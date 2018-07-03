using Omega
# using ScikitLearn

<<<<<<< HEAD
# @sk_import mixture: GaussianMixture

# include("./read_data.jl")
=======
@sk_import mixture: GaussianMixture
Omega.defaultomega() = Omega.SimpleΩ{Int, Array}

include("./read_data.jl")
σ(x) = one(x) / (one(x) + exp(-x))

Omega.lift(:σ, 1)

male_idx = 62
female_idx = 63

num_features = 108

rich_idx = 110
poor_idx = 109
>>>>>>> origin/learn

# # Read data
# train_data_X, train_data_Y, test_data_X, test_data_X = get_train_and_test()

# # Define the population model

# mixture_data = vcat(train_data_X, train_data_Y)

# mixture_data = transpose(mixture_data)

<<<<<<< HEAD
# clf = GaussianMixture(n_components=2, covariance_type="full")

# fit!(clf, mixture_data)

# weights = Array(clf["weights_"])

# means = Array(clf["means_"])

# covars = Array(clf["covariances_"])

weights = [0.5, 0.5]
means = [rand(110) for i = 1:2]
covars = [eye(110) for i = 1:2]
=======
n_train_rows = size(mixture_data)[1]

m_mixture_data = [mixture_data[i,:] for i=1:n_train_rows if mixture_data[i,male_idx] > mixture_data[i,female_idx]]

f_mixture_data = [mixture_data[i,:] for i=1:n_train_rows if mixture_data[i,male_idx] < mixture_data[i,female_idx]]

m_clf = GaussianMixture(n_components=2, covariance_type="full")
f_clf = GaussianMixture(n_components=2, covariance_type="full")

fit!(m_clf, m_mixture_data)
fit!(f_clf, f_mixture_data)

m_weights = Array(m_clf["weights_"])
f_weights = Array(f_clf["weights_"])

m_means = Array(m_clf["means_"])
f_means = Array(f_clf["means_"])

m_covars = Array(m_clf["covariances_"])
f_covars = Array(f_clf["covariances_"])
>>>>>>> origin/learn

function rand_gaussian_mixture(weights, means, covars)
    cat_var = Omega.categorical(weights)
    compots = []

    for (mean, covar) in zip(means, covars)
        push!(compots, Omega.mvnormal(mean, covar))
        # logistic_arry = [Omega.logistic(mean[i],1.0) for i = 1:length(mean)]
        # push!(compots, Omega.logistic(mean, randarray(logistic_arry)))
    end

    function mixture(ω)
        cat = cat_var(ω[@id])
        comp = compots[cat]
        return comp(ω[@id])
    end
end

m_pop_ = rand_gaussian_mixture(m_weights, m_means, m_covars)
m_pop = iid(m_pop_)

f_pop_ = rand_gaussian_mixture(f_weights, f_means, f_covars)
f_pop = iid(f_pop_)

# define the classifier
W = randarray([normal(0.0, 1.0) for i = 1:num_features])
b = normal(0.0, 1.0)

function linear_model(ω, pop_model, W, b)
    ret = b(ω)
    for i = 1:num_features
        ret += pop_model(ω)[i] * W[i](ω)
    end
    return σ(ret) > 0.5
end

function linear_model2(ω, data, W, b)
    ret = b
    for i = 1:num_features
        ret += data[i] * W[i]
    end
    return σ(ret) > 0.5
end

m_isrich_(ω) = linear_model(ω, m_pop_, W, b)
f_isrich_(ω) = linear_model(ω, f_pop_, W, b)

m_isrich = iid(m_isrich_; T = Bool)
f_isrich = iid(f_isrich_; T = Bool)

isrich2(data) = iid(linear_model2, data, W, b)

train_data_Y_bin = [train_data_Y[2,i] > train_data_Y[1,i] for i = 1 : size(train_data_Y)[2]]

# datacond = randarray([1-(1-(isrich2(train_data_X[:,i]) == train_data_Y_bin[i])) * (1 - bernoulli(0.1)) for i = size(train_data_X)[2]])
# datacond = [(isrich2(train_data_X[:,i]) == train_data_Y_bin[i]) | boolbernoulli(0.1) for i = 1:size(train_data_X)[2]]
datacond = [(isrich2(train_data_X[:,i]) == train_data_Y_bin[i]) | boolbernoulli(0.1) for i = 1:10]
# datacond = randarray(datacond)
faircond = (prob(f_isrich ∥ (W,b), 10) / prob(m_isrich ∥ (W,b), 10) > 0.85)#
W_samples = rand(W, &(faircond, datacond...))

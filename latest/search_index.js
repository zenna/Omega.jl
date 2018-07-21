var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Omega.jl-1",
    "page": "Home",
    "title": "Omega.jl",
    "category": "section",
    "text": "Omega.jl is a small programming language for causal and probabilistic reasoning. It was developed by Zenna Tavares with help from Javier Burroni, Edgar Minasyan, Xin Zhang, Rajesh Ranganath and Armando Solar Lezama."
},

{
    "location": "index.html#Quick-Start-1",
    "page": "Home",
    "title": "Quick Start",
    "category": "section",
    "text": "Omega is built in Julia 0.7 but not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with:(v0.7) pkg> add https://github.com/zenna/Omega.jl.gitCheck Omega is working and gives reasonable results with: julia> using Omega\n\njulia> rand(normal(0.0, 1.0))\n0.7625637212030862With that, see the Tutorial for a run through of the main features of Omega. "
},

{
    "location": "index.html#Contribute-1",
    "page": "Home",
    "title": "Contribute",
    "category": "section",
    "text": "We want your contributions!Probabilistic models\nContribute an inference procedure"
},

{
    "location": "index.html#Citation-1",
    "page": "Home",
    "title": "Citation",
    "category": "section",
    "text": "If you use Omega, please cite Omega paper. <!– If you use the causal inference features, please cite. –> In addition, if you use the higher-order features, please cite the random conditional distribution paper."
},

{
    "location": "index.html#Acknowledgements-1",
    "page": "Home",
    "title": "Acknowledgements",
    "category": "section",
    "text": "Omega leans heavily on the hard work of many packages and the Julia community as a whole, but in particular Distributions.jl, Flux.jl, and Cassette.jl."
},

{
    "location": "index.html#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "basictutorial.html#",
    "page": "Basic Tutorial",
    "title": "Basic Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "basictutorial.html#Basic-Tutorial-1",
    "page": "Basic Tutorial",
    "title": "Basic Tutorial",
    "category": "section",
    "text": "In this tutorial we will run through the basics of creating a model and conditioning it.First let\'s load Omega:using OmegaNext, create a beta-bernoulli distribution. This means, our prior belief about the weight of the coin is beta distributed. A beta distribution is useful because it is continuous and bounded between 0 and 1. weight = betarv(2.0, 2.0)Draw a 10000 samples from weight using randbeta_samples = rand(weight, 10000)Let\'s see what this distribution looks like using UnicodePlots.  If you don\'t hae it installed alreay install with:(v0.7) pkg> add UnicodePlotsTo visualize the distribution, plot a histogram of the samples.julia> UnicodePlots.histogram(beta_samples)             ┌────────────────────────────────────────┐ \n   (0.0,0.1] │▇▇▇▇▇▇ 279                              │ \n   (0.1,0.2] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 727                   │ \n   (0.2,0.3] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1218       │ \n   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1354    │ \n   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1482 │ \n   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1426  │ \n   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1406   │ \n   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1124         │ \n   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 702                    │ \n   (0.9,1.0] │▇▇▇▇▇▇ 282                              │ \n             └────────────────────────────────────────┘The distribution is symmetric around 0.5 but there is nonzero probability that the weight could be anything between 0 and 1.So far we have not done anything we couldn\'t do with Distributions.jl.We will create a model representing four flips of the coin. Since a coin can be heads or tales, the appropriate distribution is the bernouli distribution:nflips = 4\ncoinflips_ = [bernoulli(weight) for i = 1:nflips]Take note that the weight is the random variable defined previously.coinflips is a normal Julia array of Random Variables (RandVars). For reasons we will elaborate in later sections, it will be useful to have an Array-valued RandVar (instead of an Array of RandVar).One way to do this (there are several ways discuseed later), is to use the function randarraycoinflips = randarray(coinflips)coinflips is a RandVar and hence we can sample from it with randjulia> rand(coinflips)\n4-element Array{Float64,1}:\n 0.0\n 0.0\n 0.0\n 0.0\n\njulia> rand(coinflips)\n4-element Array{Float64,1}:\n 0.0\n 1.0\n 0.0\n 0.0\n\njulia> rand(coinflips)\n4-element Array{Float64,1}:\n 1.0\n 1.0\n 1.0\n 1.0Now we can condition the model. We want to find the conditional distribution over the weight of the coin given some observations.First we create some fake data, and then use rand to draw conditional samples:observations = [true, true, true, false]\nweight_samples = rand(weight, coinflips == observations, RejectionSample)In this case, rand takesA random variable we want to sample from\nA predicate (type RandVar{Bool}) that we want to condition on, i.e. assert that it is true\nAn inference algorithm.  Here we use rejction samplingPlot a histogram of the weights like before:julia> UnicodePlots.histogram(weight_samples)\n             ┌────────────────────────────────────────┐ \n   (0.1,0.2] │▇ 4                                     │ \n   (0.2,0.3] │▇▇▇ 22                                  │ \n   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇ 69                          │ \n   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 147             │ \n   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 185       │ \n   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 226 │ \n   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 203     │ \n   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 120                 │ \n   (0.9,1.0] │▇▇▇▇ 23                                 │ \n             └────────────────────────────────────────┘ \nObserve that our belief about the weight has now changed. We are more convinced the coin is biased towards heads (true) <!–  TODO: Describe Coin Model In English TODO: Show Corresponding Omega progromamDemonstrate unconditional sampling with rand\nDemonstrate pointwise application\nDemonstrate Random Arrays –>"
},

{
    "location": "model.html#",
    "page": "Modeling",
    "title": "Modeling",
    "category": "page",
    "text": "In Omega a probabilistic model is a collection of  random variable.The simplest random variable you can construct is the perhaps the standard uniformx1 = uniform(0.0, 1.0)x is a random variable not a sample. To construct another random variable x2, we do the same. x2 = uniform(0.0, 1.0)x1 and x2 are identically distributed and independent (i.i.d.)julia> rand((x1, x2))\n(0.5602978842341093, 0.9274576159629635)Omega comes with a large number of in-built distributions, and so to make complex probabilistic you can simply use these and compose them."
},

{
    "location": "model.html#Explicit-Style-1",
    "page": "Modeling",
    "title": "Explicit Style",
    "category": "section",
    "text": "The above style is convenient but it hides a lot of the machinery of what is going on. Omega, as well as all probabilistic programming languages, use programs to represent probability distributions However, there are several different probability distribution.Omega is distinct from other probabilistic programming langauges because it represents. In Omegax(\\omega) = \\omega(1)"
},

{
    "location": "inference.html#",
    "page": "Inference",
    "title": "Inference",
    "category": "page",
    "text": ""
},

{
    "location": "inference.html#Inference-1",
    "page": "Inference",
    "title": "Inference",
    "category": "section",
    "text": "Omega have several inference algorithms built in, and provides the mechanism to build your own."
},

{
    "location": "conditioning.html#",
    "page": "Conditioning",
    "title": "Conditioning",
    "category": "page",
    "text": ""
},

{
    "location": "conditioning.html#Conditioning-1",
    "page": "Conditioning",
    "title": "Conditioning",
    "category": "section",
    "text": "The primary purpose of building a probabilic program is to put it to use in inference.  Omega supports causal inference through the cond function."
},

{
    "location": "higher.html#",
    "page": "Higher Order Inference",
    "title": "Higher Order Inference",
    "category": "page",
    "text": ""
},

{
    "location": "higher.html#Higher-Order-Inference-1",
    "page": "Higher Order Inference",
    "title": "Higher Order Inference",
    "category": "section",
    "text": "Another unique property of Omega is our approach to higher-order inference with rcd and rid. Many probabilistic programming languages are built on languages which support higher-order functions and hence are themselves called higher-order probabilistic programming languages. Omega has a different"
},

{
    "location": "higher.html#Random-Conditional-Distribution-1",
    "page": "Higher Order Inference",
    "title": "Random Conditional Distribution",
    "category": "section",
    "text": "EXPLAIN RCDIn Omega, rcd is implemented with a functionrcd"
},

{
    "location": "higher.html#Random-Interventional-Distribution-1",
    "page": "Higher Order Inference",
    "title": "Random Interventional Distribution",
    "category": "section",
    "text": ""
},

{
    "location": "causal.html#",
    "page": "Causal Inference",
    "title": "Causal Inference",
    "category": "page",
    "text": ""
},

{
    "location": "causal.html#Causal-Inference-1",
    "page": "Causal Inference",
    "title": "Causal Inference",
    "category": "section",
    "text": "Omega supports causal inference through the change function and higher-order causal inference through the random interventional distributionCausal inference is a topic of much confusion. If you are familiar with what "
},

{
    "location": "distributions.html#",
    "page": "Built-in Distributions",
    "title": "Built-in Distributions",
    "category": "page",
    "text": ""
},

{
    "location": "distributions.html#Built-In-Distributions-1",
    "page": "Built-in Distributions",
    "title": "Built In Distributions",
    "category": "section",
    "text": "Omega comes with a number of built in probability distributions."
},

{
    "location": "distributions.html#Omega.bernoulli",
    "page": "Built-in Distributions",
    "title": "Omega.bernoulli",
    "category": "function",
    "text": "Bernoulli with weight p\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.boolbernoulli",
    "page": "Built-in Distributions",
    "title": "Omega.boolbernoulli",
    "category": "function",
    "text": "Bool - valued Bernoulli distribution (as opposed to Float64 valued)\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.betarv",
    "page": "Built-in Distributions",
    "title": "Omega.betarv",
    "category": "function",
    "text": "Beta distribution parameters α  and β\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.β",
    "page": "Built-in Distributions",
    "title": "Omega.β",
    "category": "function",
    "text": "Beta distribution parameters α  and β\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.categorical",
    "page": "Built-in Distributions",
    "title": "Omega.categorical",
    "category": "function",
    "text": "Categorical distribution with probability weight vector p\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.dirichlet",
    "page": "Built-in Distributions",
    "title": "Omega.dirichlet",
    "category": "function",
    "text": "Dirichlet distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.exponential",
    "page": "Built-in Distributions",
    "title": "Omega.exponential",
    "category": "function",
    "text": "Exponential Distribution with λ\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.gammarv",
    "page": "Built-in Distributions",
    "title": "Omega.gammarv",
    "category": "function",
    "text": "Gamma distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.Γ",
    "page": "Built-in Distributions",
    "title": "Omega.Γ",
    "category": "function",
    "text": "Gamma distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.inversegamma",
    "page": "Built-in Distributions",
    "title": "Omega.inversegamma",
    "category": "function",
    "text": "Inverse Gamma distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.kumaraswamy",
    "page": "Built-in Distributions",
    "title": "Omega.kumaraswamy",
    "category": "function",
    "text": "Kumaraswamy distribution, similar to beta but easier\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.logistic",
    "page": "Built-in Distributions",
    "title": "Omega.logistic",
    "category": "function",
    "text": "Logistic Distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.poisson",
    "page": "Built-in Distributions",
    "title": "Omega.poisson",
    "category": "function",
    "text": "Poisson distribution with rate parameter λ\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.normal",
    "page": "Built-in Distributions",
    "title": "Omega.normal",
    "category": "function",
    "text": "Normal Distribution with mean μ and variance σ\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.mvnormal",
    "page": "Built-in Distributions",
    "title": "Omega.mvnormal",
    "category": "function",
    "text": "Multivariate Normal Distribution with mean vector μ and covariance Σ\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.uniform",
    "page": "Built-in Distributions",
    "title": "Omega.uniform",
    "category": "function",
    "text": "Uniform distribution with lower bound a and upper bound b\n\n\n\n\n\nUniform sample from vector\n\n\n\n\n\nDiscrete uniform distribution with range range\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Omega.rademacher",
    "page": "Built-in Distributions",
    "title": "Omega.rademacher",
    "category": "function",
    "text": "Rademacher distribution\n\n\n\n\n\n"
},

{
    "location": "distributions.html#Univariate-Distributions-1",
    "page": "Built-in Distributions",
    "title": "Univariate Distributions",
    "category": "section",
    "text": "bernoulli\nboolbernoulli\nbetarv\nβ\ncategorical\ndirichlet\nexponential\ngammarv\nΓ\ninversegamma\nkumaraswamy\nlogistic\npoisson\nnormal\nmvnormal\nuniform\nrademacher"
},

{
    "location": "distributions.html#Multivariate-Distributions-1",
    "page": "Built-in Distributions",
    "title": "Multivariate Distributions",
    "category": "section",
    "text": "mvnormal"
},

{
    "location": "contrib.html#",
    "page": "Contribution Guide",
    "title": "Contribution Guide",
    "category": "page",
    "text": ""
},

{
    "location": "contrib.html#Contribution-1",
    "page": "Contribution Guide",
    "title": "Contribution",
    "category": "section",
    "text": "Omega makes a strict distrinction between the model and the inference algorithms. This makes it easy to add new inference algorithms to Omega.Here we will describe how to implement a very simple inference procedure: rejection sampling.The first step is to define a new abstract type that sub types Algorithm\"My Rejection Sampling\"\nabstract type MyRejectionSample <: Algorithm endThen add a method to Base.rand with the following type\"Sample from `x | y == true` with rejection sampling\"\nfunction Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{MyRejectionSample};\n                   n = 100,\n                   cb = default_cbs(n)) where {OT <: Ω}The first argument ΩT::Type{OT} is the type of Omega that will be passed through.\ny::RandVar is a random predicate that is being conditioned on\nalg::Type{MyRejectionSample} should be as writtenThe remaining arguments are optional n is the number of samples, and cb are callbacksThe implementation is then\"Sample from `x | y == true` with rejection sampling\"\nfunction Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{MyRejectionSample};\n                   n = 100,\n                   cb = default_cbs(n)) where {OT <: Ω}\n  # Run all callbacks\n  cb = runall(cb)\n\n  # Set of samples in Omega to return\n  samples = ΩT[]\n\n  # The number which have been accepted\n  accepted = 1\n  i = 1\n  while accepted < n\n    ω = ΩT()\n    if epsilon(y(ω)) == 1.0\n      push!(samples, ω)\n      accepted += 1\n      cb(RunData(ω, accepted, 0.0, accepted), Outside)\n    else\n      cb(RunData(ω, accepted, 1.0, i), Outside)\n    end\n    i += 1\n  end\n  samples\nend"
},

]}

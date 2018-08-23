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
    "text": "Omega.jl is a programming language for causal and probabilistic reasoning. It was developed by Zenna Tavares with help from Javier Burroni, Edgar Minasyan, Xin Zhang, Rajesh Ranganath and Armando Solar Lezama."
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
    "text": "In this tutorial we will run through the basics of creating a model and conditioning it.First load Omega:using OmegaIf you tossed a coin and observed the sequqnce HHHHH, you would be a little suspicious, HHHHHHHH would make you very suspicious. Elementary probability theory tells us that for a fair coin, HHHHHHHH is just a likely outcome as HHTTHHTH.  What gives?  We will use Omega to model this behaviour, and see how that belief about a coin changes after observing a number of tosses.Model the coin as a bernoulli distribution.  The weight of a bernoulli determines the probability it comes up true (which represents heads). Use a beta distribution to represent our prior belief weight of the coin.weight = β(2.0, 2.0)A beta distribution is appropriate here because it is bounded between 0 and 1. Draw a 10000 samples from weight using rand:beta_samples = rand(weight, 10000)Let\'s see what this distribution looks like using UnicodePlots.  If you don\'t have it installed already install with:(v0.7) pkg> add UnicodePlotsTo visualize the distribution, plot a histogram of the samples:julia> UnicodePlots.histogram(beta_samples)             ┌────────────────────────────────────────┐ \n   (0.0,0.1] │▇▇▇▇▇▇ 279                              │ \n   (0.1,0.2] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 727                   │ \n   (0.2,0.3] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1218       │ \n   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1354    │ \n   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1482 │ \n   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1426  │ \n   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1406   │ \n   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1124         │ \n   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 702                    │ \n   (0.9,1.0] │▇▇▇▇▇▇ 282                              │ \n             └────────────────────────────────────────┘The distribution is symmetric around 0.5 and has support over the the interval [0, 1].So far we have not done anything we couldn\'t do with Distributions.jl. A primary distinction between a package like Distribution.jl, is that Omega.jl allows you to condition probability distributions.Create a model representing four flips of the coin. Since a coin can be heads or tales, the appropriate distribution is the bernouli distribution:nflips = 4\ncoinflips_ = [bernoulli(weight) for i = 1:nflips]Take note that weight is the random variable defined previously.coinflips is a normal Julia array of Random Variables (RandVars). For reasons we will elaborate in later sections, it will be useful to have an Array-valued RandVar (instead of an Array of RandVar).One way to do this (there are several ways discuseed later), is to use the function randarraycoinflips = randarray(coinflips_)coinflips is a RandVar and hence we can sample from it with randjulia> rand(coinflips)\n4-element Array{Float64,1}:\n 0.0\n 0.0\n 0.0\n 0.0\n\njulia> rand(coinflips)\n4-element Array{Float64,1}:\n 0.0\n 1.0\n 0.0\n 0.0\n\njulia> rand(coinflips)\n4-element Array{Float64,1}:\n 1.0\n 1.0\n 1.0\n 1.0Now we can condition the model. We want to find the conditional distribution over the weight of the coin given some observations.First create some fake dataobservations = [true, true, true, false]and then use rand to draw conditional samples:weight_samples = rand(weight, coinflips == observations, 10, RejectionSample)weight_samples is a set of 10 samples from the conditional (sometimes called posterior) distribution of weight condition on the fact that coinflips == observations.In this case, rand takesA random variable we want to sample from\nA predicate (type RandVar{Bool}) that we want to condition on, i.e. assert that it is true\nAn inference algorithm.  Here we use rejection samplingPlot a histogram of the weights like before:julia> UnicodePlots.histogram(weight_samples)\n             ┌────────────────────────────────────────┐ \n   (0.1,0.2] │▇ 4                                     │ \n   (0.2,0.3] │▇▇▇ 22                                  │ \n   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇ 69                          │ \n   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 147             │ \n   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 185       │ \n   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 226 │ \n   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 203     │ \n   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 120                 │ \n   (0.9,1.0] │▇▇▇▇ 23                                 │ \n             └────────────────────────────────────────┘ \nObserve that our belief about the weight has now changed. We are more convinced the coin is biased towards heads (true)."
},

{
    "location": "model.html#",
    "page": "Modeling",
    "title": "Modeling",
    "category": "page",
    "text": "In Omega a probabilistic model is a collection of random variables. Random Variables are of type RandVar. There are two ways to construct random variables: the statistical style, which can be less verbose, and more intuitive, but has some limitations, and the explicit style, which is more general."
},

{
    "location": "model.html#Statistical-Style-1",
    "page": "Modeling",
    "title": "Statistical Style",
    "category": "section",
    "text": "In the statistical style we create random variables by combining a number of primitives. Omega comes with a number of built-in primitive distributions, the simplest of which is (arguably) the standard uniform:x1 = uniform(0.0, 1.0)x1 is a random variable not a sample. To construct another random variable x2, we do the same. x2 = uniform(0.0, 1.0)x1 and x2 are identically distributed and independent (i.i.d.).julia> rand((x1, x2))\n(0.5602978842341093, 0.9274576159629635)Contrast this with:julia> rand((x1, x1))\n(0.057271529749001626, 0.057271529749001626)"
},

{
    "location": "model.html#Composition-1",
    "page": "Modeling",
    "title": "Composition",
    "category": "section",
    "text": "Statistical style is convenient because it allows us to treat a RandVar{T} as if it is a value of type T.  For instance the typeof(uniform(0.0, 1.0)) is RandVar{Float64}.  Using the statistical style, we can add, multiply, divide them as if they were values of type Float64.x3 = x1 + x2Note x3 is a RandVar{Float64} like x1 and x2This includes inequalities:p = x3 > 1.0p is of type RandVar{Bool}julia> rand(p)\nfalseA particularly useful case is that primitive distributions which take parameters of type T, also accept RandVar{T}n = normal(x3, 1.0)Suppose you write your own function defined on the reals:myfunc(x::Float64, y::Float64) = (x * y)^2We can\'t automatically apply myfunc to RandVars; it will cause a method errorjulia> myfunc(x1, x2)\nERROR: MethodError: no method matching myfunc(::RandVar..., ::RandVar...)However this is easily remedied with the function lift:lift(myfunc)(x1, x2)"
},

{
    "location": "model.html#Explicit-Style-1",
    "page": "Modeling",
    "title": "Explicit Style",
    "category": "section",
    "text": "The above style is convenient but has a few limitations and it hides a lot of the machinery. To create random variables in the explicit style, create a normal julia sampler, but it is essential to pass through the rng object.For instance, to define a bernoulli distribution in explicit style:x_(rng) = rand(rng) > 0.5x_ is just a normal julia function.  We could sample from it by passing in the GLOBAL_RNGjulia> x_(Base.Random.GLOBAL_RNG)\ntrueHowever, in order to use x for conditional or causal inference we must turn it into a RandVar using ciid.x = ciid(x_)Statistical style and functional style can be combined naturally. For example:x = ciid(rng -> rand(rng) > 0.5 ? rand(rng)^2 : sqrt(rand(rng)))\ny = normal(0.0, 1.0)\nz = x + y"
},

{
    "location": "model.html#Random-Variable-Families-1",
    "page": "Modeling",
    "title": "Random Variable Families",
    "category": "section",
    "text": "Often we want to parameterize a random variable.  To do this we create functions with addition argument, and pass arguments to ciid.uniform(rng, a, b) = rand(rng) * (b - a) + b  \nx = ciid(10, 20)And hence if we wanted to create a method that created independent uniformly distributed random variables, we could do it like so:uniform(a, b) = ciid(rng -> rand(rng) * (b - a) + b)"
},

{
    "location": "conditionalindependence.html#",
    "page": "(Conditional) Independence",
    "title": "(Conditional) Independence",
    "category": "page",
    "text": ""
},

{
    "location": "conditionalindependence.html#Conditionally-Independence-1",
    "page": "(Conditional) Independence",
    "title": "Conditionally Independence",
    "category": "section",
    "text": "Previously we saw that we could use ciid to turn a function rng into a RandVar."
},

{
    "location": "conditionalindependence.html#Independent-Random-Variables-1",
    "page": "(Conditional) Independence",
    "title": "Independent Random Variables",
    "category": "section",
    "text": "Use iid(x) to create a random variable that is identical in distribution to x but but independent."
},

{
    "location": "conditionalindependence.html#Conditionally-Independent-Random-Variables-1",
    "page": "(Conditional) Independence",
    "title": "Conditionally Independent Random Variables",
    "category": "section",
    "text": "Use ciid(x) to create a random variable that is identical in distribution to x but conditionally independent given its parents.μ = uniform(0.0, 1.0)\ny1 = normal(μ, 1.0)\ny2 = ciid(y1)\nrand((y1, y2))"
},

{
    "location": "inference.html#",
    "page": "Conditional Inference",
    "title": "Conditional Inference",
    "category": "page",
    "text": ""
},

{
    "location": "inference.html#Inference-1",
    "page": "Conditional Inference",
    "title": "Inference",
    "category": "section",
    "text": "The primary purpose of building a probabilistic model is to use it for inference."
},

{
    "location": "inference.html#Base.rand",
    "page": "Conditional Inference",
    "title": "Base.rand",
    "category": "function",
    "text": "Random ω ∈ Ω\n\n\n\n\n\nSample n from x\n\n\n\n\n\nSample 1 from x\n\n\n\n\n\nn samples from x with rejection sampling\n\n\n\n\n\nSample ω | y == true with Metropolis Hasting\n\n\n\n\n\nSample from x | y == true with Single Site Metropolis Hasting\n\n\n\n\n\nSample from x | y == true with Hamiltonian Monte Carlo\n\n\n\n\n\nSample from x | y == true with Hamiltonian Monte Carlo\n\n\n\n\n\nrand(s::Sampleable)\n\nGenerate one sample for s.\n\nrand(s::Sampleable, n::Int)\n\nGenerate n samples from s. The form of the returned object depends on the variate form of s:\n\nWhen s is univariate, it returns a vector of length n.\nWhen s is multivariate, it returns a matrix with n columns.\nWhen s is matrix-variate, it returns an array, where each element is a sample matrix.\n\n\n\n\n\nrand(d::UnivariateDistribution)\n\nGenerate a scalar sample from d. The general fallback is quantile(d, rand()).\n\nrand(d::UnivariateDistribution, n::Int) -> Vector\n\nGenerates a vector of n random scalar samples from d. The general fallback is to pick random samples from sampler(d).\n\n\n\n\n\nrand(d::MultivariateDistribution)\n\nSample a vector from the distribution d.\n\nrand(d::MultivariateDistribution, n::Int) -> Vector\n\nSample n vectors from the distribution d. This returns a matrix of size (dim(d), n), where each column is a sample.\n\n\n\n\n\nrand(rng::AbstractRNG, d::AbstractMvNormal)\nrand(rng::AbstractRNG, d::AbstractMvNormal, n::Int)\nrand!(rng::AbstractRNG, d::AbstractMvNormal, x::AbstractArray)\n\nSample from distribution d using the random number generator rng.\n\n\n\n\n\nrand(d::MatrixDistribution, n)\n\nDraw a sample matrix from the distribution d.\n\n\n\n\n\nrand(d::Union{UnivariateMixture, MultivariateDistribution})\n\nDraw a sample from the mixture model d.\n\nrand(d::Union{UnivariateMixture, MultivariateMixture}, n)\n\nDraw n samples from d.\n\n\n\n\n\n"
},

{
    "location": "inference.html#Conditional-Sampling-Algorithms-1",
    "page": "Conditional Inference",
    "title": "Conditional Sampling Algorithms",
    "category": "section",
    "text": "While there are several kinds of things you would like to know about a conditional distribution (e.g., its mode) currently, all inference algorithms perform conditional sampling only. To sample from a conditional distribution: pass two random variables to rand, the distribution you want to sample from, and the predicate you want to condition on. For example:weight = β(2.0, 2.0)\nx = bernoulli()\nrand(weight, x == 0)It is fine to condition random variables on equalities or inequalities:x1 = normal(0.0, 1.0)\nx2 = normal(0.0, 10)\nrand((x1, x2), x1 + x2 > == 0.0)Note: to sample from more than one random variable, just pass a tuple of RandVars to rand, e.g.:Omega.rand"
},

{
    "location": "inference.html#Omega.cond",
    "page": "Conditional Inference",
    "title": "Omega.cond",
    "category": "function",
    "text": "Condition random variable x with random predicate RandVar which returns Bool or SoftBool.\n\nx = normal(0.0, 1.0)\nx_ = cond(x, x > 0)\n\n\n\n\n\nCondition random variable with predicate: cond(x, p) = cond(x, p(x)) cond(poisson(0.5), iseven\n\n\n\n\n\nCondition within a function\n\nfunction x_(ω)\n  x = 0.0\n  xs = Float64[]\n  while bernoulli(ω, 0.8, Bool)\n    x += uniform(ω, -5.0, 5.0)\n    cond(ω, x <=ₛ 1.0)\n    cond(ω, x >=ₛ -1.0)\n    push!(xs, x)\n  end\n  xs\nend\n\nx = ciid(x_)\nsamples = rand(x, 100; alg = SSMH)\n\n\n\n\n\n"
},

{
    "location": "inference.html#Conditioning-with-cond-1",
    "page": "Conditional Inference",
    "title": "Conditioning with cond",
    "category": "section",
    "text": "rand(x, y) is simply a shorter way of saying rand(cond(x, y)). That is, the primary mechanism for inference in Omega is conditioning random variables using cond.cond"
},

{
    "location": "inference.html#Conditioning-the-Prior-1",
    "page": "Conditional Inference",
    "title": "Conditioning the Prior",
    "category": "section",
    "text": "In Bayesian inference the term posterior distribution is often used instead of conditional distribution.  Mathematically they are the same objec, but posterior alludes to the fact that it is the distribution after (post) observing data. Prior to observing data, your distribution is the prior.However, conditioning is a more general concept than observing data, and we can meaningfully \"condition the prior\".For example we can make a truncated normal distribution with:x = normal(0.0, 1.0)\nx_ = cond(x, x > 0.0)A shorter way to write this is to pass a unary function as the second argument to condx = cond(normal(0.0, 1.0), rv -> rv > 0.0)Or suppose we want a poisson distribution over the even numberscond(poission(1.0), iseven)"
},

{
    "location": "inference.html#Conditions-Propagate-1",
    "page": "Conditional Inference",
    "title": "Conditions Propagate",
    "category": "section",
    "text": "When you compose condiitoned random variables together, their conditions propagate.  That is, if x is conditioned, and y is conditioned, and z depends on x and y, then z inherits all the conditions of x and y automatically.  For example:ispos(x) = x > 0.0\nweight = cond(normal(72, 1.0), ispos)\nheight = cond(normal(1.78, 1.0), ispos)\nbmi = weight / heightbmi is a function of both weight and height, both of which have their own conditions (namely, they are positive). Omega automatically propagates the conditions from weight and height onto bmi respects these conditions."
},

{
    "location": "soft.html#",
    "page": "Soft Execution",
    "title": "Soft Execution",
    "category": "page",
    "text": ""
},

{
    "location": "soft.html#Soft-Execution-1",
    "page": "Soft Execution",
    "title": "Soft Execution",
    "category": "section",
    "text": ""
},

{
    "location": "soft.html#TLDR-1",
    "page": "Soft Execution",
    "title": "TLDR",
    "category": "section",
    "text": "For inference problems which are continuous or high dimensional, use soft predicates to use more efficient inference routines.==\n>ₛ\n>=\n<=ₛ\n<ₛIf the values x and y are not standard numeric types you will need to define a notation of distance.  Override Omega.ddFor example:struct\n  \nend"
},

{
    "location": "soft.html#Relaxation-1",
    "page": "Soft Execution",
    "title": "Relaxation",
    "category": "section",
    "text": "In Omega you condition on predicates. A predicate is any function whose domain is Boolean. These are sometimes called indicator functions, or characteristic functions. In particular, in Omega we condition on Bool valued random variables:x = normal(0.0, 1.0)\ny = x == 1.0\nrand(y)From this perspective, conditioning means to solve a constraint. It can be difficult to solve these constraints exactly, and so Omega supports softened constraints to make inference more tractable.There are two ways to make soft constraints.  The first way is explicitly:julia> x = normal(0.0, 1.0)\njulia> y = x ≊ 1.0\njulia> rand(y)\nϵ:-47439.72956833765Suppose we construct a random variable of the form x == y. The soft version we would write x ==\\_s y (or softeq(x, y)). These softened functions have the form:If \\rho(x, y) denote a distance between x and y.$k(\\rho(x, y)) $\n## Controlling the kernel\n\n\nOmega has a number of built-in kernels:\n@docs kse\n## Soft Function Application\nThere are a couple of drawbacks from explicitly using soft constraints in the model:\n\n1. We have changed the model for what is a problem of inference\n2. Often we may be using pre-existing code and not be able to easily replace all the constraints with soft constraints\n\nOmega has an experimental feature which automatically does soft execution of a normal predicate.  Soft application relies on e\njulia julia> g(x::Real)::Bool = x > 0.5 julia> softapply(g, 0.3) ϵ:-2000.0 ```This feature is experimental because Cassette is waiting on a number of compiler optimizations to make this efficient."
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
    "text": "Omega supports causal inference through the replace function and higher-order causal inference through the random interventional distribution rid. Causal inference is a topic of much confusion, we recommend this blog post for a primer."
},

{
    "location": "causal.html#Base.replace",
    "page": "Causal Inference",
    "title": "Base.replace",
    "category": "function",
    "text": "Causal Intervention: Set θold to θnew in x\n\n\n\n\n\nCausal Intervention: Set θold to θnew in x\n\n\n\n\n\n"
},

{
    "location": "causal.html#Causal-Intervention-the-replace-operator-1",
    "page": "Causal Inference",
    "title": "Causal Intervention - the replace operator",
    "category": "section",
    "text": "The replace operator models an intervention to a model. It changes the model.replaceIn Omega we use the syntax:replace(X, θold => θnew)To mean the random variable X where θold has been replaced with θnew.  For this to be meaningful, θold must be a parent of x.Let\'s look at an example:julia> μold = normal(0.0, 1.0)\n45:Omega.normal(0.0, 1.0)::Float64\n\njulia> x = normal(μold, 1.0)\n46:Omega.normal(Omega.normal, 1.0)::Float64\n\njulia> μnew = 100.0\n47:Omega.normal(100.0, 1.0)::Float64\n\njulia> xnew = replace(x, μold => μnew)\njulia> rand((x, xnew))\n(-2.664230595692529, 96.99998702926271)Observe that the sample from xnew is much greater, because it has the mean of the normal distribution has been changed to 100"
},

{
    "location": "causal.html#Replace-a-Random-Variable-with-a-Random-Variable-1",
    "page": "Causal Inference",
    "title": "Replace a Random Variable with a Random Variable",
    "category": "section",
    "text": "Repacing a random variable with a constant is actually a special case of replacing a random variable with a number random variable.  The inference is the samejulia> xnewnew = replace(x, μold => normal(200.0, 1.0))\njulia> rand((x, xnew, xnewnew))\n(-1.2756627673001866, 99.1080578175426, 198.14711316585564)"
},

{
    "location": "causal.html#Changing-Multiple-Variables-1",
    "page": "Causal Inference",
    "title": "Changing Multiple Variables",
    "category": "section",
    "text": "replace allow you to change many variables at once  Simply pass in a variable number of pairs, or a dictionary."
},

{
    "location": "causal.html#Example-1",
    "page": "Causal Inference",
    "title": "Example",
    "category": "section",
    "text": "We can use replace and cond separately and in combination to ask lots of different kinds of questions. In this example, we model the relationship betwee the weather outside and teh thermostat reading inside a house. Broadly, the model says that the weather outside is dictataed by the time of day, while the temperature inside is determined by whether the air conditioning is on, and whether the window is open.First, setup simple priors over the time of day, and variables to determine whether the air conditioning is on and whether hte iwndow is open:timeofday = uniform([:morning, :afternoon, :evening])\nis_window_open = bernoulli(0.5)\nis_ac_on = bernoulli(0.3)Second, assume that the outside temperature depends on the time of day, being hottest in the afternoon, but cold at night:function outside_temp_(rng)\n  if timeofday(rng) == :morning\n    normal(rng, 20.0, 1.0)\n  elseif timeofday(rng) == :afternoon\n    normal(rng, 32.0, 1.0)\n  else\n    normal(rng, 10.0, 1.0)\n  end\nendRemember, in this style we have to use  ciid to convert a function into a RandVaroutside_temp = ciid(outside_temp_, T=Float64)The inside_temp before considering the effects of the window is room temperature, unless the ac is on, which makes it colder.function inside_temp_(rng)\n  if Bool(is_ac_on(rng))\n    normal(rng, 20.0, 1.0)\n  else\n    normal(rng, 25.0, 1.0)\n  end\nend\n\ninside_temp = ciid(inside_temp_, T=Float64)47:Omega.normal(100.0, 1.0)::Float64Finally, the thermostat reading is inside_temp if the window is closed (we have perfect insulation), otherwise it\'s just the average of the outside and inside temperaturefunction thermostat_(rng)\n  if Bool(is_window_open(rng))\n    (outside_temp(rng) + inside_temp(rng)) / 2.0\n  else\n    inside_temp(rng)\n  end\nend\n\nthermostat = ciid(thermostat_, T=Float64)Now with the model built, we can ask some questions:"
},

{
    "location": "causal.html#Samples-from-the-prior-1",
    "page": "Causal Inference",
    "title": "Samples from the prior",
    "category": "section",
    "text": "The simplest task is to sample from the prior:julia> rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat), 5, alg = RejectionSample)\n5-element Array{Any,1}:\n (:afternoon, 0.0, 0.0, 32.349, 26.441, 26.441)   \n (:afternoon, 1.0, 0.0, 30.751, 25.143, 27.947)\n (:morning, 1.0, 0.0, 16.928, 24.146, 20.537)     \n (:afternoon, 1.0, 0.0, 30.521, 25.370, 27.946)\n (:morning, 1.0, 1.0, 16.495, 20.203, 18.349) "
},

{
    "location": "causal.html#Conditional-Inference-1",
    "page": "Causal Inference",
    "title": "Conditional Inference",
    "category": "section",
    "text": "You enter the room and the thermostat reads hot. what does this tell you about the variables?samples = rand((timeofday, iswindowopen, isacon, outsidetemp, insidetemp, thermostat),                 thermostat > 30.0, 5, alg = RejectionSample)\njulia> samples = rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat),\n                       thermostat > 30.0, 5, alg = RejectionSample)\n5-element Array{Any,1}:\n (:evening, 1.0, 0.0, 33.64609872046609, 26.822449458789542, 30.234274089627817) \n (:afternoon, 1.0, 0.0, 34.37763909867243, 26.16221853550574, 30.269928817089088)\n (:evening, 1.0, 0.0, 34.32198183192978, 26.6773921624331, 30.499686997181442)   \n (:afternoon, 1.0, 0.0, 34.05126597960254, 26.51833791813246, 30.2848019488675)  \n (:afternoon, 1.0, 0.0, 32.92982568498735, 27.56800059609554, 30.248913140541447)"
},

{
    "location": "causal.html#Counter-Factual-1",
    "page": "Causal Inference",
    "title": "Counter Factual",
    "category": "section",
    "text": "If I were to close the window, and turn on the AC would that make it hotter or colder\"thermostatnew = replace(thermostat, is_ac_on => 1.0, is_window_open => 0.0)\ndiffsamples = rand(thermostatnew - thermostat, 10000, alg = RejectionSample)\njulia> mean(diffsamples)\n-4.246869797640215So in expectation, that intervention will make the thermostat colder.  But we can look more closely at the distribution:julia> UnicodePlots.histogram([diffsamples...])\n\n                 ┌────────────────────────────────────────┐ \n   (-11.0,-10.0] │ 37                                     │ \n    (-10.0,-9.0] │▇▇▇▇ 502                                │ \n     (-9.0,-8.0] │▇▇▇▇▇▇▇▇▇▇▇ 1269                        │ \n     (-8.0,-7.0] │▇▇▇▇▇ 581                               │ \n     (-7.0,-6.0] │▇▇▇▇ 497                                │ \n     (-6.0,-5.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 3926 │ \n     (-5.0,-4.0] │▇ 65                                    │ \n     (-4.0,-3.0] │ 5                                      │ \n     (-3.0,-2.0] │ 3                                      │ \n     (-2.0,-1.0] │▇ 97                                    │ \n      (-1.0,0.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1960                  │ \n       (0.0,1.0] │▇▇▇▇ 494                                │ \n       (1.0,2.0] │▇▇ 197                                  │ \n       (2.0,3.0] │▇▇ 237                                  │ \n       (3.0,4.0] │▇ 118                                   │ \n       (4.0,5.0] │ 12                                     │ \n                 └────────────────────────────────────────┘ In what scenarios would it still be hotter after turning on the AC and closing the window?rand((timeofday, outsidetemp, insidetemp, thermostat),       thermostatnew - thermostat > 0.0, 10, alg = RejectionSample)"
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
    "text": "Omega comes with a number of built-in probability distributions."
},

{
    "location": "distributions.html#Univariate-Distributions-1",
    "page": "Built-in Distributions",
    "title": "Univariate Distributions",
    "category": "section",
    "text": "bernoulli\nboolbernoulli\nbetarv\ncategorical\nconstant\nexponential\ngammarv\ninversegamma\nkumaraswamy\nlogistic\npoisson\nnormal\nuniform\nrademacher"
},

{
    "location": "distributions.html#Multivariate-Distributions-1",
    "page": "Built-in Distributions",
    "title": "Multivariate Distributions",
    "category": "section",
    "text": "mvnormal\ndirichlet"
},

{
    "location": "distributions.html#Describe-distributional-functions-1",
    "page": "Built-in Distributions",
    "title": "Describe distributional functions",
    "category": "section",
    "text": "Omega comes with some functions which summarize an entire distribution. Most of these are inherited from Distributions.jlmean\nprob"
},

{
    "location": "omega.html#",
    "page": "Omega",
    "title": "Omega",
    "category": "page",
    "text": ""
},

{
    "location": "omega.html#Omega-1",
    "page": "Omega",
    "title": "Omega",
    "category": "section",
    "text": "As described in [models], random variables are thin wrappers around functions which take as input a value ω::Ω We previously described Ω as a type of AbstractRNG.  This is true, but the full store is a bit more complex"
},

{
    "location": "omega.html#Omega.Space.Ω",
    "page": "Omega",
    "title": "Omega.Space.Ω",
    "category": "type",
    "text": "Probability Space indexed with values of type I\n\n\n\n\n\n"
},

{
    "location": "omega.html#Omega.Space.SimpleΩ",
    "page": "Omega",
    "title": "Omega.Space.SimpleΩ",
    "category": "type",
    "text": "Fast SimpleΩ\n\nProperties\n\nFast tracking (50 ns overhead)\nFast to get linear view\nHence easy to sample from\nUnique index for each rand value and hence: (i) Memory intensive\n\n\n\n\n\n"
},

{
    "location": "omega.html#Ω-1",
    "page": "Omega",
    "title": "Ω",
    "category": "section",
    "text": "Ω is an abstract type which represents a sample space in probability theory.ΩSimpleΩ"
},

{
    "location": "omega.html#Samplers-vs-Random-Variables-1",
    "page": "Omega",
    "title": "Samplers vs Random Variables",
    "category": "section",
    "text": "A sampler and a random variable have many similarities but are different. To demonstrate the difference, we shall show the changes one has to make to turn a sampler into an Omega RandVar.Create a sampler that x1() = rand() > 0.5x1 uses Random.GLOBAL_RNG in the background.  Instead, make it explicit:julia> x2(rng::AbstractRNG) = rand(rng) > 0.5\njulia> x2(Random.MersenneTwister())\nfalseMake a cosmetic changejulia> x2(rng::AbstractRNG) = rand(rng) > 0.5\njulia> x2(Random.MersenneTwister())\nfalse"
},

{
    "location": "cheatsheet.html#",
    "page": "Cheat Sheet",
    "title": "Cheat Sheet",
    "category": "page",
    "text": ""
},

{
    "location": "cheatsheet.html#Cheat-Sheet-1",
    "page": "Cheat Sheet",
    "title": "Cheat Sheet",
    "category": "section",
    "text": ""
},

{
    "location": "cheatsheet.html#Core-Functions-1",
    "page": "Cheat Sheet",
    "title": "Core Functions",
    "category": "section",
    "text": "The major functions that you will use in Omega are:ciid(x) : that is equal in distribution to x but conditionally independent given parents\niid(x) : that is equal in distribution to x but independent\ncond(x, y) : condition random variable x on condition y\nrand(x, n; alg=Alg) : n samples from (possibly conditioned) random variable x using algorithm ALG\nreplace(x, θold => θnew) : causal intervention in random variable\nrid(x, θ)  : distribution interventional distribution of x given θ  \nrcd(x, θ) or x ∥ θ  : random conditional distribution of x given θ"
},

{
    "location": "cheatsheet.html#Built-in-Distributions-1",
    "page": "Cheat Sheet",
    "title": "Built-in Distributions",
    "category": "section",
    "text": "bernoulli(w) boolbernoulli(w) betarv categorical constant exponential gammarv inversegamma kumaraswamy logistic poisson normal uniform rademacher"
},

{
    "location": "cheatsheet.html#Built-in-Inference-Algorithms-1",
    "page": "Cheat Sheet",
    "title": "Built-in Inference Algorithms",
    "category": "section",
    "text": "RejectionSample MI SSMH HMC SGHMC HMCFAST"
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

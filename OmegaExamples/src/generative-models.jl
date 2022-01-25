### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ ec0d1440-51ea-11ec-0aef-1f9c2da69ffd
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ ce896412-97f8-4102-9ed5-bc74dfdb26d4
md"### Models, simulation, and degrees of belief"

# ╔═╡ cd268cc7-e246-4254-94eb-4809e96b224b
md"One view of knowledge is that the mind maintains working models of parts of the world. ‘Model’ in the sense that it captures some of the structure in the world, but not all (and what it captures need not be exactly what is in the world—just what is useful). ‘Working’ in the sense that it can be used to simulate this part of the world, imagining what will follow from different initial conditions."

# ╔═╡ f68ca668-e238-4aa2-82be-c2320336e2e9
md"# Building Generative Models"

# ╔═╡ 2cd7584f-5c78-4d3a-93dc-16da97146e98
md"We wish to describe in formal terms how to generate states of the world. That is, we wish to describe the causal process, or steps that unfold, leading to some potentially observable states. The key idea of this section is that these generative processes can be described as computations—computations that involve random choices to capture uncertainty about the process.
Programming languages are formal systems for describing what (deterministic) computation a computer should do. Modern programming languages offer a wide variety of different ways to describe computation; each makes some processes simple to describe and others more complex. However, a key tenet of computer science is that all of these languages have the same fundamental power: any computation that can be described with one programming language can be described by another. (More technically this Church-Turing thesis posits that many specific computational systems capture the set of all effectively computable procedures. These are called universal systems.)"

# ╔═╡ cb28a5c4-a721-4a53-a179-adedf4f71237
md"""
[Omega](https://github.com/zenna/Omega.jl) is a programming language that describes causal probabilistic models anad supports causal and probabilistic inference in these models. 
The key idea is that in Omega you can express probabilistic generative models as simulation programs.
"""

# ╔═╡ 0ce18f90-f2ef-490a-a7c4-40a6ccfa214a
md"""
A basic object in Omega is a random variable.  Conceptually, a random variable represents an uncertain value.  Omega comes with a small number of built-in random variables.  For example, `a` defined in the following line is Normally distributed random variable with mean 0 and variance 1:
"""

# ╔═╡ 354e3b5a-4d1e-43ee-b1bb-e8620fba49e7
a = @~ StdNormal{Float64}()

# ╔═╡ 35a567c0-13aa-4a8a-bd75-68fef7b15739


# ╔═╡ 9dca3d31-8ace-4c64-996c-d9d9e87e6ee4
md"### Sampling "

# ╔═╡ cc0c0d70-5197-4b2f-b32d-6ac52b8daf27
md"`randsample` is used to sample from a random variable:"

# ╔═╡ d607d2e0-84a5-4dfd-a281-f5c64cfe1e2d
randsample(a)

# ╔═╡ 0360ccef-ccf4-4284-80a9-ee5ed40becc4
md"### Primitive and Composite Classes in Omega"

# ╔═╡ 7d3c8448-090d-46b4-a6b6-ba20ff617be8
md"A class is analogous to a [*plate*](https://en.wikipedia.org/wiki/Plate_notation) in Bayesian networks."

# ╔═╡ 4bd6d241-aad3-466c-b19e-c52e36eab862
md"class, from which you can generate random variables. For instance, a rando" 

# ╔═╡ 9998d466-eb74-476f-a768-d378bbe83f1b
md"""##### Primitive Classes
Omega comes with a set of built-in primitive random variable classes, such as `StdNormal` and `StdUniform`. A class represents an collection of random variables.
"""

# ╔═╡ a0d64a28-e4f9-4003-b69d-7b27bd757c24
As = StdUniform{Float64}()

# ╔═╡ 0b9f8239-d81b-4e52-a97c-bcd6a286d096
md"To create the a random variable of a class we use the `~` function. `rv` below is the 1st element of a class of (standard) uniformly distributed random variables"

# ╔═╡ 84acb184-1c92-4761-a44e-bd1503f8255d
rv = 1 ~ As

# ╔═╡ 4e80ce71-6757-4908-8cd0-e382b11b70c3
randsample(rv)

# ╔═╡ 5fd22c50-4c81-41b2-a959-fe3dec00a6fd
md"""
##### Composite Class

A class in Omega is actually just function of the form `f(id, ω)`. You can specify your own classes simply by constructing such a function.
"""

# ╔═╡ 8ac4cad4-eb4c-4e33-815c-e365668b3810
μ = 1 ~ StdNormal{Float64}()

# ╔═╡ 5fcf6c97-6f81-4be2-b27a-25b2abcabca1
x(id, ω) = (id ~ StdNormal{Float64}) (μ(ω), 1))(ω)

# ╔═╡ 1b4d9047-abb0-4fb7-ab72-0a4f790b1515
x_ = 3 ~ x

# ╔═╡ 0fe48b01-e908-4e6c-8c4c-b68cf8c172dc
md"`x_` is a random variable of the class `x`"

# ╔═╡ 0a2c3c83-8a67-4666-80c0-f580233dc019
randsample((μ, x_))

# ╔═╡ f2a20f84-b2e6-4e6c-ab51-6e7ea045954e
md"Alternatively, `@joint` is used to create the joint distribution of variables:"

# ╔═╡ 7d5587d1-c4b4-48f0-971c-677fbe268e73
joint = @joint μ x_

# ╔═╡ ae0ad1df-ab2a-4704-a121-623e05f079da
randsample(joint)

# ╔═╡ ddfbc392-d9b2-409a-9838-aa26cec5a945
md"##### Automatic IDS"

# ╔═╡ 0ae343fa-bc62-48ac-a34e-d21028531530
md"""
Every time we create a new (independent) random variable, we need to provide a unique id to it. In many scenarios we don't care about the specific id, we only care that oen random variable is different from another.  In Omega, we can instead use `@~` to generate `id`s automatically. For example, to simulate a coin toss, we can simply write:
"""

# ╔═╡ 3c73f032-eedf-4d99-8489-a98ccf4b8805
coin_toss = @~ Bernoulli()

# ╔═╡ ee7616ad-59ed-4073-bb9d-3c5939649226
md"This is equivalent to the following, where `@uid` greates a unique id"

# ╔═╡ 61f4d77b-eecf-4cca-ac01-944efe58d9bb
@uid() ~ Bernoulli()

# ╔═╡ 2ad90265-8ef2-480f-81b0-7ed1a674011b
md"If you run the program many times, and collect the values in a histogram, you can see what a typical sample looks like:"

# ╔═╡ 9504162b-52e1-476d-8218-0afc2555e278
viz(randsample(coin_toss, 1000))

# ╔═╡ 15920581-2258-42e1-ba73-da82b2baa7e0
md"As you can see, the result is an approximately uniform distribution over true(1) and false(0).
This way we can construct more complex expressions that describe more complicated random variables. For instance, here we describe a process that samples a number adding up several independent Bernoulli distributions:"

# ╔═╡ 3f04b226-a38a-4804-8691-59332bfc8728
b_sum = (@~ Bernoulli()) .+ (@~ Bernoulli()) .+ (@~ Bernoulli())

# ╔═╡ 9bc6817f-4874-43f9-a5be-e71d5b18f7b9
md"`+ₚ` here is pointwise sum - the subscript p denotes the pointwise operation defined on a function"

# ╔═╡ db8d667c-5ad7-4deb-b020-13d645bedbf9
randsample(b_sum)

# ╔═╡ 5444fd8d-8ff3-4b30-9942-067dca8a1126
md"We have constructed a random variable that is a sum of three random variables and sampled from it. We can construct such complex random variables from the primitive ones."

# ╔═╡ 09595cc9-b08a-4465-a3e0-5d8e280530a2
viz(randsample(b_sum, 1000))

# ╔═╡ 6aa46f74-b3e2-4d12-abd0-90759023ecc5
md"Complex functions can also have other arguments. Here is a random variable that will only sometimes double its input:"

# ╔═╡ 0974a6a9-859f-44a9-a17a-5ef90c789ce5
noisy_double(x) = ifelseₚ((@~ Bernoulli()), 2*x, x)

# ╔═╡ 317cf40e-bafd-43f3-b855-9bfcf53c0f3a
md"`pw` is the pointwise operation - which is defined on the function `ifelse` here."

# ╔═╡ 11c2d2b5-0c14-4b23-9282-083ac6f07f6f
randsample(noisy_double(3))

# ╔═╡ c697307c-9d49-43a7-a379-f383780a1248
md"By using higher-order functions we can construct and manipulate complex sampling processes. We use the `ifelseₚ` function: `ifelseₚ(condition, if-true, if-false)` to induce hierarchy. A good example comes from coin flipping…"

# ╔═╡ 277b383e-c909-4424-91f1-f0f00b3531b4
md"## Example: Flipping Coins"

# ╔═╡ f58cd6ff-9023-4dc7-9213-2279f5aebf72
md"The following program defines a fair coin, and flips it $20$ times:"

# ╔═╡ 3c5e0f1d-0379-4c92-817d-4e6ef2d7ed8e
fair_coin = ifelseₚ((@~ Bernoulli()), 'h', 't')

# ╔═╡ b7d24774-2f2b-4da8-9257-6fe3a424a869
viz(randsample(fair_coin, 20))

# ╔═╡ a54a2d2f-4c4b-46b1-aa7a-2ca5e6203067
md"This program defines a “trick” coin that comes up heads most of the time ($95\%$), and flips it $20$ times:"

# ╔═╡ 5657d115-ebad-4731-b8e2-5d66da76f600
trick_coin = ifelseₚ((@~ Bernoulli(0.95)), 'h', 't')

# ╔═╡ 83f9117e-2c5b-47e8-a78f-3bd679ad95dc
viz(randsample(trick_coin, 20))

# ╔═╡ 65e02cf5-bfd2-4d79-899c-57a64624dd71
md"The higher-order function `make_coin` takes in a weight and outputs a function describing a coin with that weight. Then we can use `make_coin` to make the coins above, or others."

# ╔═╡ 65119d8b-a0d9-403f-9d42-ec6ef0ab3072
make_coin(weight) = ifelseₚ((@~ Bernoulli(weight)), 'h', 't')

# ╔═╡ 7fb8ded9-629a-4084-ba5b-779dbe251841
begin
	fair_coin1 = make_coin(0.5)
	trick_coin1 = make_coin(0.95)
	bent_coin = make_coin(0.25)
end

# ╔═╡ 7ff75111-cdde-466f-8b85-572a0e8a68bd
viz(randsample(fair_coin1, 20))

# ╔═╡ 31f991a8-eb5e-413b-a3db-3058a6bde18d
viz(randsample(trick_coin1, 20))

# ╔═╡ 8c354058-4168-4591-9a16-778031ec1d3a
viz(randsample(bent_coin, 20))

# ╔═╡ 15dacfed-9db5-4a3e-ba21-edbfcb3dc690
md"We can also define a higher-order function that takes a “coin” and “bends it”:"

# ╔═╡ 56304079-fc6c-474b-b257-9db330475786
bend(coin) = ifelseₚ((coin ==ₚ 'h'), make_coin(0.7), make_coin(0.1))

# ╔═╡ 4c343506-221d-4e8f-9398-725643bd74fc
bent_coin1 = bend(fair_coin)

# ╔═╡ 0d487cd0-e3d6-4623-98ea-a4dc649a0d9e
viz(randsample(bent_coin1, 100))

# ╔═╡ 7d668805-db8f-4d76-812f-d9d86f44668e
md"Here we visualize the number of heads we expect to see if we flip a weighted coin ($weight = 0.8$) $10$ times. We’ll repeat this experiment 1000 times and then visualize the results. Try varying the coin weight or the number of repetitions to see how the expected distribution changes."

# ╔═╡ 7a7711ba-65ea-459e-be55-da5f3e36a990
begin
	make_coin_binary(weight, n) = n ~ Bernoulli(weight)
	coin(n) = make_coin_binary(0.8, n)
end

# ╔═╡ 500b46f9-f081-46d1-9fbf-5704c1068a75
c = pw(+, [coin(i) for i in 1:10]...)

# ╔═╡ 83b2661d-a893-44a8-8138-13779356a7c0
viz(randsample(c, 1000))

# ╔═╡ deb917d9-f885-4b7f-a85e-f2fcfab91183
md"## Example: Causal Models in Medical Diagnosis"

# ╔═╡ 4ef4f0dc-eb00-4fd0-a951-7e7d508cab06
md"Generative knowledge is often causal knowledge that describes how events or states of the world are related to each other. As an example of how causal knowledge can be encoded in Omega, consider a simplified medical scenario:"

# ╔═╡ 74534019-62ee-494f-8ece-ac2d096543d9
let
	lung_cancer = @~ Bernoulli(0.01)
	cold = @~ Bernoulli(0.2)
	cough = cold |ₚ lung_cancer
	randsample(cough)
end

# ╔═╡ 4c21551f-75c3-4e9d-ac9f-aed939481c2e
md"This program models the diseases and symptoms of a patient in a doctor’s office. It first specifies the base rates of two diseases the patient could have: lung cancer is rare while a cold is common, and there is an independent chance of having each disease. The program then specifies a process for generating a common symptom of these diseases – an effect with two possible causes: The patient coughs if they have a cold or lung cancer (or both).
Here is a more complex version of this causal model:"

# ╔═╡ 17701d52-161b-447d-892f-3ca89d461ebd
begin
	lung_cancer = @~ Bernoulli(0.01)
	TB = @~ Bernoulli(0.005)
	stomach_flu = @~ Bernoulli(0.1)
	cold = @~ Bernoulli(0.2)
	other = @~ Bernoulli(0.1)
end

# ╔═╡ 24a06c1c-29ac-45b3-b8fa-774ca2e4619e
cough = pw(|, 
	cold &ₚ @~ Bernoulli(), 
	lung_cancer &ₚ @~ Bernoulli(0.3), 
	TB &ₚ @~ Bernoulli(0.7), 
	other &ₚ @~ Bernoulli(0.1)
)

# ╔═╡ f5600317-7a50-4f16-9716-c4e3e24515bb
noisy(x, p) = x &. Bernoullli(p)
fever = pw(|, 
	(cold &ₚ @~ Bernoulli(0.3)), 
	(stomach_flu &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli(0.1)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ f005e508-db7f-4d3d-997e-3bdbe0c4bb7e
chest_pain = pw(|, 
	(lung_cancer &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli()), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 3dfc6973-f996-4020-b461-016b46f87659
shortness_of_breath = pw(|, 
	(lung_cancer &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli(0.2)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 47807da5-e1b6-49aa-849b-39d5cce05471
symptoms = @joint cough fever chest_pain shortness_of_breath

# ╔═╡ f755a265-1b88-47e2-97ee-5269964ff809
randsample(symptoms)

# ╔═╡ ceb6e5a8-8093-425e-b40d-9bd345c23e66
md"Now there are four possible diseases and four symptoms. Each disease causes a different pattern of symptoms. The causal relations are now probabilistic: Only some patients with a cold have a cough ($50\%$), or a fever ($30\%$). There is also a catch-all disease category “other”, which has a low probability of causing any symptom. Noisy logical functions—functions built from and (`&ₚ`), or (`|ₚ`), and distributions —provide a simple but expressive way to describe probabilistic causal dependencies between Boolean (true-false valued) variables.
When you run the above code, the program generates a list of symptoms for a hypothetical patient. Most likely all the symptoms will be false, as (thankfully) each of these diseases is rare. Experiment with running the program multiple times. Now try modifying the function for one of the diseases, setting it to be true, to simulate only patients known to have that disease. For example, replace `lung_cancer = @~ Bernoulli(0.01)` with `lung_cancer = true`. Run the program several times to observe the characteristic patterns of symptoms for that disease."

# ╔═╡ 83aa6c42-a846-42d7-b9d0-c5b9e783c2cc
md"## Prediction, Simulation, and Probabilities"

# ╔═╡ 2cf11ab5-0fdf-43da-8987-2bed91ef3f14
md"Suppose that we flip two fair coins, and return the tuple of their values:"

# ╔═╡ 54890932-a472-4ad4-a904-bc847551bfcb
randsample(((@~ Bernoulli()), (@~ Bernoulli())))

# ╔═╡ 1721f226-8d1d-4803-a445-925874e236c8
md"How can we predict the return value of this program? For instance, how likely is it that we will see `(true, false)`? A probability is a number between $0$ and $1$ that expresses the answer to such a question: it is a degree of belief that we will see a given outcome, such as `(true, false)`. The probability of an event $A$ (such as the above program returning `(true, false)`) is usually written as $P(A)$.
A probability distribution is the probability of each possible outcome of an event. For instance, we can examine the probability distribution on values that can be returned by the above program by sampling many times and examining the histogram of return values:"

# ╔═╡ f2fd33e0-3451-44cb-9e69-8b627abf7729
begin 
	random_pair = ((@~ Bernoulli()), (@~ Bernoulli()))
	viz(string.(randsample(random_pair, 1000)))
end

# ╔═╡ a066a0a9-e28f-45ef-bfba-ef23eaf75f96
md"We see by examining this histogram that `(true, false)` comes out about $25\%$ of the time. We may define the probability of a return value to be the fraction of times (in the long run) that this value is returned from evaluating the program – then the probability of `(true, false)` from the above program is $0.25$."

# ╔═╡ 98da911f-1338-4651-9e20-aaeab6c81c50
md"## The rules of probability"

# ╔═╡ 27fe69b6-ba83-4b79-8f30-df5841650e23
md"We can derive marginal distributions with the “rules of probability”. This is intractable for complex processes, but can help us build intuition for how distributions work."

# ╔═╡ 10e3b2f2-68ec-4c19-b473-469a47815205
md"#### Product Rule"

# ╔═╡ 8283c98e-23eb-4a34-b4f2-14722a4afbe7
md"In the above example, we take three steps to compute the output value: we create the first Bernoulli random variable, then the second, then we make a tuple of random variables and sample from it. To make this more clear let us re-write the program as:"

# ╔═╡ 0add56e4-adba-448b-a6bc-8c17284bda01
let
	A = @~ Bernoulli()
	B = @~ Bernoulli()
	C = @joint A B
	randsample(C)
end

# ╔═╡ 547eeca0-202d-4b43-8fc8-7d81c054bd02
md"We can directly observe (as we did above) that the probability of true for $A$ is $0.5$, and the probability of false from $B$ is $0.5$. Can we use these two probabilities to arrive at the probability of $0.25$ for the overall outcome `C = (true, false)`? Yes, using the product rule of probabilities: The probability of two random choices is the product of their individual probabilities. The probability of several random choices together is often called the joint probability and written as $P(A,B)$. Since the first and second random choices must each have their specified values in order to get `(true, false)` in the example, the joint probability is their product: $0.25$.

We must be careful when applying this rule, since the probability of a choice can depend on the probabilities of previous choices. For instance, we can visualize the the exact probability of `(true, false)` resulting from this program by defining a new random variable as follows -"

# ╔═╡ 25276e86-a816-4d37-baf2-6761971a9090
A = @~ Bernoulli()

# ╔═╡ 1c260eff-636c-429d-992f-b7854f4398e1
B = @~ Bernoulli(ifelseₚ(A, 0.3, 0.7))

# ╔═╡ d57d23a3-7626-4b23-b1df-994951f5a12b
rs = randsample((A, B), 1000)

# ╔═╡ 4a0255be-6b88-4f1b-80c0-eec1d70c0da6
viz(string.(rs))

# ╔═╡ 4fc6e919-7026-4c13-88fe-bd7956e1bb6e
md"In general, the joint probability of two random choices $A$ and $B$ made sequentially, in that order, can be written as $P(A,B)=P(A)P(B|A)$. This is read as the product of the probability of $A$ and the probability of “$B$ given $A$”, or “$B$ conditioned on $A$”. That is, the probability of making choice $B$ given that choice $A$ has been made in a certain way. Only when the second choice does not depend on (or “look at”) the first choice does this expression reduce to a simple product of the probabilities of each choice individually: $P(A,B)=P(A)P(B)$.
What is the relation between $P(A,B)$ and $P(B,A)$, the joint probability of the same choices written in the opposite order? The only logically consistent definitions of probability require that these two probabilities be equal, so $P(A)P(B|A)=P(B)P(A|B)$. This is the basis of Bayes’ theorem, which we will encounter later."

# ╔═╡ 099b62b4-3b0a-4f78-a1c0-2cb04cb4d35c
md"#### Sum Rule"

# ╔═╡ fad672e1-3888-40dc-8358-b75a1b71c628
md"Now let’s consider an example where we can’t determine from the overall return value the sequence of random choices that were made:"

# ╔═╡ d744dba4-580b-4795-95c6-e4197c4217d6
s = (@~ Bernoulli()) |ₚ (@~ Bernoulli())

# ╔═╡ ebdc9cec-32db-4770-9fc8-8400280a48cb
randsample(s)

# ╔═╡ 21400744-aa27-4360-91ed-63f397d475ee
md"We can sample from this program and determine that the probability of returning true is about $0.75$.
We cannot simply use the product rule to determine this probability because we don’t know the sequence of random choices that led to this return value. However we can notice that the program will return true if the two-component choices are `(true, true)`, or `(true, false)`, or `(false, true)`. To combine these possibilities we use another rule for probabilities: If there are two alternative sequences of choices that lead to the same return value, the probability of this return value is the sum of the probabilities of the sequences. We can write this using probability notation as: $P(A)=∑P(A,B)$ over all $B$, where we view $A$ as the final value and $B$ as a random choice on the way to that value. Using the product rule we can determine that the probability in the example above is $0.25$ for each sequence that leads to return value true, then, by the sum rule, the probability of true is $0.25+0.25+0.25=0.75$.
Using the sum rule to compute the probability of a final value is called is sometimes called marginalization, because the final distribution is the marginal distribution on final values. From the point of view of sampling processes marginalization is simply ignoring (or not looking at) intermediate random values that are created on the way to a final return value. From the point of view of directly computing probabilities, marginalization is summing over all the possible “histories” that could lead to a return value. Putting the product and sum rules together, the marginal probability of return values from a program that we have explored above is the sum over sampling histories of the product over choice probabilities—a computation that can quickly grow unmanageable, but can be approximated."

# ╔═╡ 548d888e-2dd7-4a3d-b43c-21955283a920
md"#### Stochastic recursion"

# ╔═╡ 24263dd7-8700-479c-a49a-0a311571af7e
md"Recursive functions are a powerful way to structure computation in deterministic systems. In Omega it is possible to have a stochastic recursion that randomly decides whether to stop. For example, the geometric distribution is a probability distribution over the non-negative integers. We imagine flipping a (weighted) coin, returning $N−1$ if the first true is on the $N$th flip (that is, we return the number of times we get false before our first true):"

# ╔═╡ 4bc21863-2b27-4eeb-86e4-7a2e85db26e1
geometric(p, ω, n = 0) = (n ~ Bernoulli(p))(ω) ? 0 : 1 + geometric(p, ω, n + 1)

# ╔═╡ 0f25507b-23d1-4cbf-8669-c90fab519fe9
randsample(ω -> geometric(0.6, ω))

# ╔═╡ f31df26e-0f92-4957-8569-05c10f4adec8
md"There is no upper bound on how long the computation can go on, although the probability of reaching some number declines quickly as we go. Indeed, stochastic recursions must be constructed to halt eventually (with probability $1$)."

# ╔═╡ 073f84a2-8cc8-4683-bff5-a2849806ecb7
md"## Persistent Randomness"

# ╔═╡ bfd0556a-9363-4040-bcfa-bec0ce28ba4a
md"In Omega, random variables are pure: reapplication to the same context (or ω) produces the same result."

# ╔═╡ 7238ccd2-68c8-4839-bec2-de26dbe6a473
ω = defω()

# ╔═╡ 18438de3-24e6-4d21-a008-951bda316f46
f = 1 ~ Bernoulli()

# ╔═╡ cbe819fc-d2f3-49dd-bef2-55fef0e8210b
g = 1 ~ Bernoulli()

# ╔═╡ 82a6be03-71fe-48d7-a2fa-53427f951cd2
f(ω) == g(ω) # Always returns true

# ╔═╡ 8c06cba6-e1bc-4dc0-b6c2-a2b625313d6c
md"Independent random variables of a random class can be created in Omega by changing the `id` as follows -"

# ╔═╡ a9d291a1-ab41-4756-937b-ae44a44012e4
let
	iid_1 = 1 ~ Bernoulli()
	iid_2 = 2 ~ Bernoulli()
	ω = defω()
	iid_1(ω) == iid_2(ω) # Does not always return true
end

# ╔═╡ cb5cd097-1632-46ab-b311-ab89bc827034
md"Sometimes we require the results of the stochastic process to be random but persistent, for example: Eye colour of a person. We can represent the notion that eye color is random, but each person has a fixed eye colour as follows:"

# ╔═╡ 17a5049b-68f4-4ef1-9abe-4a669a3dcdc5
function eye_colour(n, ω)
	d = (n ~ DiscreteUniform(1, 3))(ω)
	if d == 1
		return :blue
	elseif d == 2
		return :green
	else
		return :brown
	end
end

# ╔═╡ f4a3f028-b386-4748-94f7-72972d66ed6b
bob = 1

# ╔═╡ 25fa6650-8be1-468a-a705-ae2a4397ee1a
alice = 2

# ╔═╡ c91c4ccf-253b-4507-86af-975986032f9f
randsample(ω -> [eye_colour(bob, ω), eye_colour(alice, ω), eye_colour(bob, ω)])

# ╔═╡ 72c80751-7a95-4e2d-9415-83129c934bcc
md"Bob's eye colour is consistent every time we call the above `randsample`."

# ╔═╡ 7c838e1b-9ff7-45eb-8e7b-656435671e4e
md"This type of modeling is called random world style ([McAllester et al., 2008](https://dspace.mit.edu/handle/1721.1/41516)). Note that we don’t have to specify ahead of time the people whose eye color we will ask about: the distribution on eye colors is implicitly defined over the infinite set of possible people, but only constructed “lazily” when needed."

# ╔═╡ 434defef-1ec7-420b-8699-34be75cf08b2
md"As another example, here we define a function `flip_a_lot` that maps from an integer (or any other value) to a coin flip. We could use it to implicitly represent the $n$th flip of a particular coin, without having to actually flip the coin $n$ times."

# ╔═╡ ceca9345-4a5e-4766-bd54-ab4f2d4c0a6e
flip_a_lot(n, ω) = (n ~ Bernoulli())(ω)

# ╔═╡ b10cf079-1995-4af6-8ec0-f772d0e9d359
let
	randsample(ω -> [
		[flip_a_lot(1, ω), flip_a_lot(12, ω), flip_a_lot(47, ω), flip_a_lot(1548, ω)],
		[flip_a_lot(1, ω), flip_a_lot(12, ω), flip_a_lot(47, ω), flip_a_lot(1548, ω)]
	])
end

# ╔═╡ 45d75c36-5af8-4211-9432-99cabe1e1aeb
md"There are a countably infinite number of such flips, each independent of all the others. The outcome of each, once determined, will always have the same value."

# ╔═╡ Cell order:
# ╠═ec0d1440-51ea-11ec-0aef-1f9c2da69ffd
# ╟─ce896412-97f8-4102-9ed5-bc74dfdb26d4
# ╟─cd268cc7-e246-4254-94eb-4809e96b224b
# ╟─f68ca668-e238-4aa2-82be-c2320336e2e9
# ╟─2cd7584f-5c78-4d3a-93dc-16da97146e98
# ╟─cb28a5c4-a721-4a53-a179-adedf4f71237
# ╟─0ce18f90-f2ef-490a-a7c4-40a6ccfa214a
# ╠═354e3b5a-4d1e-43ee-b1bb-e8620fba49e7
# ╠═35a567c0-13aa-4a8a-bd75-68fef7b15739
# ╟─9dca3d31-8ace-4c64-996c-d9d9e87e6ee4
# ╟─cc0c0d70-5197-4b2f-b32d-6ac52b8daf27
# ╠═d607d2e0-84a5-4dfd-a281-f5c64cfe1e2d
# ╟─0360ccef-ccf4-4284-80a9-ee5ed40becc4
# ╟─7d3c8448-090d-46b4-a6b6-ba20ff617be8
# ╠═4bd6d241-aad3-466c-b19e-c52e36eab862
# ╠═9998d466-eb74-476f-a768-d378bbe83f1b
# ╠═a0d64a28-e4f9-4003-b69d-7b27bd757c24
# ╠═0b9f8239-d81b-4e52-a97c-bcd6a286d096
# ╠═84acb184-1c92-4761-a44e-bd1503f8255d
# ╠═4e80ce71-6757-4908-8cd0-e382b11b70c3
# ╟─5fd22c50-4c81-41b2-a959-fe3dec00a6fd
# ╠═8ac4cad4-eb4c-4e33-815c-e365668b3810
# ╠═5fcf6c97-6f81-4be2-b27a-25b2abcabca1
# ╠═1b4d9047-abb0-4fb7-ab72-0a4f790b1515
# ╟─0fe48b01-e908-4e6c-8c4c-b68cf8c172dc
# ╠═0a2c3c83-8a67-4666-80c0-f580233dc019
# ╟─f2a20f84-b2e6-4e6c-ab51-6e7ea045954e
# ╠═7d5587d1-c4b4-48f0-971c-677fbe268e73
# ╠═ae0ad1df-ab2a-4704-a121-623e05f079da
# ╟─ddfbc392-d9b2-409a-9838-aa26cec5a945
# ╟─0ae343fa-bc62-48ac-a34e-d21028531530
# ╠═3c73f032-eedf-4d99-8489-a98ccf4b8805
# ╟─ee7616ad-59ed-4073-bb9d-3c5939649226
# ╠═61f4d77b-eecf-4cca-ac01-944efe58d9bb
# ╟─2ad90265-8ef2-480f-81b0-7ed1a674011b
# ╠═9504162b-52e1-476d-8218-0afc2555e278
# ╟─15920581-2258-42e1-ba73-da82b2baa7e0
# ╠═3f04b226-a38a-4804-8691-59332bfc8728
# ╟─9bc6817f-4874-43f9-a5be-e71d5b18f7b9
# ╠═db8d667c-5ad7-4deb-b020-13d645bedbf9
# ╟─5444fd8d-8ff3-4b30-9942-067dca8a1126
# ╠═09595cc9-b08a-4465-a3e0-5d8e280530a2
# ╟─6aa46f74-b3e2-4d12-abd0-90759023ecc5
# ╠═0974a6a9-859f-44a9-a17a-5ef90c789ce5
# ╟─317cf40e-bafd-43f3-b855-9bfcf53c0f3a
# ╠═11c2d2b5-0c14-4b23-9282-083ac6f07f6f
# ╟─c697307c-9d49-43a7-a379-f383780a1248
# ╟─277b383e-c909-4424-91f1-f0f00b3531b4
# ╟─f58cd6ff-9023-4dc7-9213-2279f5aebf72
# ╠═3c5e0f1d-0379-4c92-817d-4e6ef2d7ed8e
# ╠═b7d24774-2f2b-4da8-9257-6fe3a424a869
# ╟─a54a2d2f-4c4b-46b1-aa7a-2ca5e6203067
# ╠═5657d115-ebad-4731-b8e2-5d66da76f600
# ╠═83f9117e-2c5b-47e8-a78f-3bd679ad95dc
# ╟─65e02cf5-bfd2-4d79-899c-57a64624dd71
# ╠═65119d8b-a0d9-403f-9d42-ec6ef0ab3072
# ╠═7fb8ded9-629a-4084-ba5b-779dbe251841
# ╠═7ff75111-cdde-466f-8b85-572a0e8a68bd
# ╠═31f991a8-eb5e-413b-a3db-3058a6bde18d
# ╠═8c354058-4168-4591-9a16-778031ec1d3a
# ╟─15dacfed-9db5-4a3e-ba21-edbfcb3dc690
# ╠═56304079-fc6c-474b-b257-9db330475786
# ╠═4c343506-221d-4e8f-9398-725643bd74fc
# ╠═0d487cd0-e3d6-4623-98ea-a4dc649a0d9e
# ╟─7d668805-db8f-4d76-812f-d9d86f44668e
# ╠═7a7711ba-65ea-459e-be55-da5f3e36a990
# ╠═500b46f9-f081-46d1-9fbf-5704c1068a75
# ╠═83b2661d-a893-44a8-8138-13779356a7c0
# ╟─deb917d9-f885-4b7f-a85e-f2fcfab91183
# ╟─4ef4f0dc-eb00-4fd0-a951-7e7d508cab06
# ╠═74534019-62ee-494f-8ece-ac2d096543d9
# ╟─4c21551f-75c3-4e9d-ac9f-aed939481c2e
# ╠═17701d52-161b-447d-892f-3ca89d461ebd
# ╠═24a06c1c-29ac-45b3-b8fa-774ca2e4619e
# ╠═f5600317-7a50-4f16-9716-c4e3e24515bb
# ╠═f005e508-db7f-4d3d-997e-3bdbe0c4bb7e
# ╠═3dfc6973-f996-4020-b461-016b46f87659
# ╠═47807da5-e1b6-49aa-849b-39d5cce05471
# ╠═f755a265-1b88-47e2-97ee-5269964ff809
# ╟─ceb6e5a8-8093-425e-b40d-9bd345c23e66
# ╟─83aa6c42-a846-42d7-b9d0-c5b9e783c2cc
# ╟─2cf11ab5-0fdf-43da-8987-2bed91ef3f14
# ╠═54890932-a472-4ad4-a904-bc847551bfcb
# ╟─1721f226-8d1d-4803-a445-925874e236c8
# ╠═f2fd33e0-3451-44cb-9e69-8b627abf7729
# ╟─a066a0a9-e28f-45ef-bfba-ef23eaf75f96
# ╟─98da911f-1338-4651-9e20-aaeab6c81c50
# ╟─27fe69b6-ba83-4b79-8f30-df5841650e23
# ╟─10e3b2f2-68ec-4c19-b473-469a47815205
# ╟─8283c98e-23eb-4a34-b4f2-14722a4afbe7
# ╠═0add56e4-adba-448b-a6bc-8c17284bda01
# ╟─547eeca0-202d-4b43-8fc8-7d81c054bd02
# ╠═25276e86-a816-4d37-baf2-6761971a9090
# ╠═1c260eff-636c-429d-992f-b7854f4398e1
# ╠═d57d23a3-7626-4b23-b1df-994951f5a12b
# ╠═4a0255be-6b88-4f1b-80c0-eec1d70c0da6
# ╟─4fc6e919-7026-4c13-88fe-bd7956e1bb6e
# ╟─099b62b4-3b0a-4f78-a1c0-2cb04cb4d35c
# ╟─fad672e1-3888-40dc-8358-b75a1b71c628
# ╠═d744dba4-580b-4795-95c6-e4197c4217d6
# ╠═ebdc9cec-32db-4770-9fc8-8400280a48cb
# ╟─21400744-aa27-4360-91ed-63f397d475ee
# ╟─548d888e-2dd7-4a3d-b43c-21955283a920
# ╟─24263dd7-8700-479c-a49a-0a311571af7e
# ╠═4bc21863-2b27-4eeb-86e4-7a2e85db26e1
# ╠═0f25507b-23d1-4cbf-8669-c90fab519fe9
# ╟─f31df26e-0f92-4957-8569-05c10f4adec8
# ╟─073f84a2-8cc8-4683-bff5-a2849806ecb7
# ╟─bfd0556a-9363-4040-bcfa-bec0ce28ba4a
# ╠═7238ccd2-68c8-4839-bec2-de26dbe6a473
# ╠═18438de3-24e6-4d21-a008-951bda316f46
# ╠═cbe819fc-d2f3-49dd-bef2-55fef0e8210b
# ╠═82a6be03-71fe-48d7-a2fa-53427f951cd2
# ╟─8c06cba6-e1bc-4dc0-b6c2-a2b625313d6c
# ╠═a9d291a1-ab41-4756-937b-ae44a44012e4
# ╟─cb5cd097-1632-46ab-b311-ab89bc827034
# ╠═17a5049b-68f4-4ef1-9abe-4a669a3dcdc5
# ╠═f4a3f028-b386-4748-94f7-72972d66ed6b
# ╠═25fa6650-8be1-468a-a705-ae2a4397ee1a
# ╠═c91c4ccf-253b-4507-86af-975986032f9f
# ╟─72c80751-7a95-4e2d-9415-83129c934bcc
# ╟─7c838e1b-9ff7-45eb-8e7b-656435671e4e
# ╟─434defef-1ec7-420b-8699-34be75cf08b2
# ╠═ceca9345-4a5e-4766-bd54-ab4f2d4c0a6e
# ╠═b10cf079-1995-4af6-8ec0-f772d0e9d359
# ╟─45d75c36-5af8-4211-9432-99cabe1e1aeb

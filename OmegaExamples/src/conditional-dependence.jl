### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ a6793602-5caa-11ec-1047-f9c7ee843ccf
begin
	import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ e32ccfe6-d204-4e2c-835f-d207a00575d4
using GraphPlot, Graphs, Colors

# ╔═╡ 7b2999d0-e66b-4212-be30-3be990be04f9
md"### From _A Priori_ Dependence to Conditional Dependence"

# ╔═╡ 68841072-3016-4de8-9fad-3d4d8be3fc5b
md"""
The relationships between causal structure and statistical dependence become particularly interesting and subtle when we look at the effects of additional observations or assumptions. Events that are statistically dependent a priori may become independent when we condition on some observation; this is called _screening off_. Also, events that are statistically independent a priori may become dependent when we condition on observations; this is known as _explaining away_. The dynamics of screening off and explaining away are extremely important for understanding patterns of inference—reasoning and learning—in probabilistic models.
"""

# ╔═╡ 5c2d0805-2039-4c42-9b86-17216dab9319
md"#### Screening off"

# ╔═╡ 346f4f4a-23ff-4ede-b95f-14b257bbaf8b
md"""
_Screening off_ refers to a pattern of statistical inference that is quite common in both scientific and intuitive reasoning. If the statistical dependence between two events `A` and `B` is only indirect, mediated strictly by one or more other events `C`, then conditioning on (observing) `C` should render `A` and `B` statistically independent. This can occur if `A` and `B` are connected by one or more causal chains, and all such chains run through the set of events `C`, or if `C` comprises all of the common causes of `A` and `B`.

For instance, let’s look again at our common cause example, this time assuming that we _already_ know the value of `C`:
"""

# ╔═╡ 035aa787-f941-43e4-937e-accefbb7498c
let
	g = DiGraph(3)
	add_edge!(g, 3 => 1)
	add_edge!(g, 3 => 2)
	gplot(g, nodelabel = [:A, :B, :C], nodefillc = colorant"seagreen", layout = 			 
 spectral_layout)
end

# ╔═╡ 34d232f9-a8bb-47ad-82e6-9280fd0bca98
C = @~ Bernoulli()

# ╔═╡ 64335ca1-48a9-435d-93f5-c71adfa71677
B = ifelseₚ(C, (@~ Bernoulli(0.5)), (@~ Bernoulli(0.9)))

# ╔═╡ 7d51eedb-d042-446f-a2f7-da7c4b3e58c2
A = ifelseₚ(C, (@~ Bernoulli(0.1)), (@~ Bernoulli(0.4)))

# ╔═╡ e6481a46-550d-443d-b4f7-9ad961a1e957
B_cond_A(A_val) = B |ᶜ (C &ₚ (A ==ₚ A_val))

# ╔═╡ 5e308604-38b3-4411-8adc-096a55e2963a
md"Histogram of `B` conditioned on when `A` is `true` :"

# ╔═╡ f002b30b-ad9d-4bc8-b38e-cc1fcb7bbc62
viz(randsample(B_cond_A(true), 1000))

# ╔═╡ 58c19d66-48a2-491a-9651-8b5340c4b4f8
md"Histogram of `B` conditioned on when `A` is `false` :"

# ╔═╡ 0e70a11d-a3d9-473a-9bcc-666d02fe56c8
viz(randsample(B_cond_A(false), 1000))

# ╔═╡ c17a0aa6-8991-4798-b478-899859a4123c
md"""
We see that `A` and `B` are statistically independent given knowledge of `C`.

Screening off is a purely statistical phenomenon. For example, consider the the causal chain model, where `A` directly causes `C`, which in turn directly causes `B`. Here, when we condition on `C` – the event that mediates an indirect causal relation between `A` and `B` – `A` and `B` are still causally dependent in our model of the world: it is just our beliefs about the states of `A` and `B` that become uncorrelated. There is also an analogous causal phenomenon. If we can actually manipulate or intervene on the causal system, and set the value of `C` to some known value, then `A` and `B` become both statistically and causally independent (by intervening on `C`, we break the causal link between `A` and `C`).
"""

# ╔═╡ 150914fd-47a5-4d70-aec7-4ab361b44aee
md"#### Explaining away"

# ╔═╡ c55b478b-737f-4b31-a90c-dec9659dfe06
md"""
“Explaining away” ([Pearl, 1988](https://scholar.google.com/scholar?q=%22Probabilistic%20reasoning%20in%20intelligent%20systems%3A%20networks%20of%20plausible%20inference%22)) refers to a complementary pattern of statistical inference which is somewhat more subtle than screening off. If two events `D` and `E` are statistically (and hence causally) independent, but they are both causes of one or more other events `F`, then conditioning on (observing) `F` can render `D` and `E` statistically dependent. Here is an example where `D` and `E` have a common _effect_:
"""

# ╔═╡ 2ab4bdcc-6300-4911-a96c-a8d71a6e7a66
let
	g = DiGraph(3)
	add_edge!(g, 1 => 3)
	add_edge!(g, 2 => 3)
	gplot(g, nodelabel = [:D, :E, :F], nodefillc = colorant"seagreen", layout = spectral_layout)
end

# ╔═╡ 6a911b82-abd4-4fb3-890d-83575a23c514
D = @~ Bernoulli()

# ╔═╡ 8a779fe1-fe21-428d-8d1e-0598e8c53e14
E = @~ Bernoulli()

# ╔═╡ 48ebe872-8c2f-477f-b09a-2c91725f590a
F = ifelseₚ((D |ₚ E), (@~ Bernoulli(0.9)), (@~ Bernoulli(0.2)))

# ╔═╡ 39496d8b-5b75-459a-b004-a6a7e3f06213
E_cond_D(D_val) = E |ᶜ (F &ₚ (D ==ₚ D_val))

# ╔═╡ 8b641417-3699-48fd-b946-94285d0359c7
md"Histogram of `E` conditioned on `D` when `D` is `true` :"

# ╔═╡ e54f25e2-1f02-4b33-a033-4f9d5fc855ef
viz(randsample(E_cond_D(true), 1000))

# ╔═╡ 4613124b-2ff9-46a5-8740-691730b55684
md"Histogram of `E` conditioned on `D` when `D` is `false` :"

# ╔═╡ 54087a09-3774-472a-987e-a67f691a9d65
viz(randsample(E_cond_D(false), 1000))

# ╔═╡ 8b154a12-b15a-4fea-83ea-2b43af19e03d
md"""
As with screening off, we only induce statistical dependence from learning about `F`, not causal dependence: when we observe `F`, `D` and `E` remain causally independent in our model of the world; it is our beliefs about `D` and `E` that becomes correlated.
"""

# ╔═╡ 93bb0b08-3cfe-429b-840f-e2628005fc84
md"""
The most typical pattern of explaining away we see in causal reasoning is a kind of _anti-correlation_: the probabilities of two possible causes for the same effect increase when the effect is observed, but they are conditionally anti-correlated, so that observing additional evidence in favor of one cause should lower our degree of belief in the other cause. (This pattern is where the term explaining away comes from.) However, the coupling induced by conditioning on common effects depends on the nature of the interaction between the causes, it is not always an anti-correlation. Explaining away takes the form of an anti-correlation when the causes interact in a roughly disjunctive or additive form: the effect tends to happen if any cause happens; or the effect happens if the sum of some continuous influences exceeds a threshold. The following simple mathematical examples show this and other patterns.

Suppose we condition on observing the sum of two integers drawn uniformly from 0 to 9:
"""

# ╔═╡ 099a9976-611d-4d0a-9e7e-e1a505df3a9a
int_1 = @~ DiscreteUniform(0, 9)

# ╔═╡ b3c69b87-405f-4cef-ba52-d0986328f739
int_2 = @~ DiscreteUniform(0, 9)

# ╔═╡ dc660eb9-2868-4773-8387-195133311851
ints = @joint int_1 int_2

# ╔═╡ 82bb2560-4003-4651-9859-ecfa664e7a22
sum_cond = ints |ᶜ (int_1 +ₚ int_2 ==ₚ 9)

# ╔═╡ 72fb2dc6-b89f-4bec-a00f-a09cdc19bfa3
val = randsample(sum_cond, 1000)

# ╔═╡ 998e9e30-af54-4ced-afb2-44e9ca5c10e1
scatterplot([v.int_1 for v in val], [v.int_2 for v in val], marker = :xcross)

# ╔═╡ 781d2a73-7060-42b2-9db0-ea0c5da76f68
md"""
This gives perfect anti-correlation in conditional inferences for `int_1` and `int_2`. But suppose we instead condition on observing that `int_1` and `int_2` are equal:
"""

# ╔═╡ 3e717d2c-ba8e-4331-87d6-e2232bedb5eb
eq_cond = ints |ᶜ (int_1 ==ₚ int_2)

# ╔═╡ 14de8534-62d2-4051-b590-403f80ab4c77
val_eq = randsample(eq_cond, 1000)

# ╔═╡ b5be4e3e-be2a-41f8-9038-773eda8b8073
scatterplot([v.int_1 for v in val_eq], [v.int_2 for v in val_eq], marker = :xcross)

# ╔═╡ f6bc26c5-ff48-48b1-b98e-9ea64df1f6f2
md"""
Now, of course, `int_1` and `int_2` go from being independent a priori to being perfectly correlated in the conditional distribution. Try out these other conditions to see other possible patterns of conditional dependence for a priori independent functions:

* `pw(abs, (int_1 -ₚ int_2)) <ₚ 2`
* `(int_1 +ₚ int_2 >=ₚ 9) &ₚ (int_1 +ₚ int_2 <=ₚ 11)`
* `pw(abs, (int_1 -ₚ int_2)) ==ₚ 2`
* `pw(%, (A -ₚ B), 10) ==ₚ 3` # (int_1 $-$ int_2) $\%$ 10 $==$ 3 
* `pw(%, int_1, 2) ==ₚ pw(%, int_2, 2)` # int_1 $\%$ 2 $==$ int_2 $\%$ 2
"""

# ╔═╡ c9e9ac6c-a2ce-45e2-8c65-c8815b65f692
md"### Non-monotonic Reasoning"

# ╔═╡ 71e44172-66f8-4989-aca6-bf1ef3964122
md"""
The medical scenario is a great model to explore screening off and explaining away. In this model `smokes` is statistically dependent on several symptoms—`cough`, `chest_pain`, and `shortness_of_breath`—due to a causal chain between them mediated by `lung_disease`. We can see this easily by conditioning on these symptoms and looking at `smokes`:
"""

# ╔═╡ f406a180-150f-47f2-a8b0-1d918738e3ec
md"""
One reason explaining away is an important phenomenon in probabilistic inference is that it is an example of non-monotonic reasoning. In formal logic, a theory is said to be monotonic if adding an assumption (or formula) to the theory never reduces the set of conclusions that can be drawn. Most traditional logics (e.g. First Order) are monotonic, but human reasoning does not seem to be. For instance, if I tell you that Tweety is a bird, you conclude that he can fly; if I now tell you that Tweety is an ostrich you retract the conclusion that he can fly. Over the years many non-monotonic logics have been introduced to model aspects of human reasoning. One of the first reasons that probabilistic reasoning with Bayesian networks was recognized as important for AI was that it could perspicuously capture these patterns of reasoning ([Pearl, 1988](https://scholar.google.com/scholar?q=%22Probabilistic%20reasoning%20in%20intelligent%20systems%3A%20networks%20of%20plausible%20inference%22)).

Another way to think about monotonicity is by considering the trajectory of our belief in a specific proposition, as we gain additional relevant information. In traditional logic, there are only three states of belief: true, false, and unknown (when neither a proposition nor its negation can be proven). As we learn more about the world, maintaining logical consistency requires that our belief in any proposition only move from unknown to true or false. That is our “confidence” in any conclusion only increases (and only does so in one giant leap from unknown to true or false).

In a probabilistic approach, by contrast, belief comes in a whole spectrum of degrees. We can think of confidence as a measure of how far our beliefs are from a uniform distribution—how close to the extremes of $0$ or $1$. In probabilistic inference, unlike in traditional logic, our confidence in a proposition can both increase and decrease. Even fairly simple probabilistic models can induce complex explaining-away dynamics that lead our degree of belief in a proposition to reverse directions multiple times as observations accumulate.
"""

# ╔═╡ 2b360158-08f5-46d2-98d8-10e764de554c
md"#### Example: Medical Diagnosis"

# ╔═╡ a2bf38d2-edc8-410f-8a3f-ec80f1bc9376
smokes = @~ Bernoulli(0.2)

# ╔═╡ 384aa2e3-c9be-4014-bac0-91adeb50a92d
lung_disease = (smokes &ₚ @~ Bernoulli(0.1)) |ₚ @~ Bernoulli(0.001)

# ╔═╡ b442387a-f1c3-4437-a7c3-4b4115625d83
cold = @~ Bernoulli(0.02)

# ╔═╡ a5b4825b-7df0-44ca-b5c0-29da7c9b7e94
cough = pw(|, 
	(cold &ₚ @~ Bernoulli()), 
	(lung_disease &ₚ @~ Bernoulli()), 
	@~ Bernoulli(0.001)) 

# ╔═╡ 58d05c77-4593-4ef3-bc81-4213bbb63def
fever = (cold &ₚ @~ Bernoulli(0.3)) |ₚ @~ Bernoulli(0.01)

# ╔═╡ 32954a31-6e3f-4689-8c9f-942553315845
chest_pain = (lung_disease &ₚ @~ Bernoulli(0.2)) |ₚ @~ Bernoulli(0.01)

# ╔═╡ 55beb01c-7598-4c54-8264-559dac01a197
shortness_of_breath = (lung_disease &ₚ @~ Bernoulli(0.2)) |ₚ @~ Bernoulli(0.01)

# ╔═╡ 885ea696-dda5-40cb-879e-47e293d0fde6
smokes_cond_c_cp_sob = smokes |ᶜ pw(&, cough, chest_pain, shortness_of_breath)

# ╔═╡ 370c6749-de71-4783-a831-02b8c692181b
viz(randsample(smokes_cond_c_cp_sob, 1000))

# ╔═╡ 7e98268f-81c5-4e63-9f34-7af0f75f415e
md"""
The conditional probability of smokes is much higher than the base rate, $0.2$, because observing all these symptoms gives strong evidence for smoking. See how much evidence the different symptoms contribute by dropping them out of the conditioning set. (For instance, try conditioning on `cough &ₚ chest_pain`, or just `cough`; you should observe the probability of `smokes` decrease as fewer symptoms are observed.)

Now, suppose we condition also on knowledge about the function that mediates these causal links: `lung_disease`. Is there still an informational dependence between these various symptoms and `smokes`? In the Inference below, try adding and removing various symptoms (`cough`, `chest_pain`, `shortness_of_breath`) but maintaining the observation `lung_disease`:
"""

# ╔═╡ 30b6fb25-2c81-4975-bc52-1c31ce79047b
smokes_cond_c_cp_sob_ld = 
	smokes |ᶜ pw(&, lung_disease, cough, chest_pain, shortness_of_breath)

# ╔═╡ 7cd38ff5-e93b-4ad4-ac94-4b1b2042a063
md"""
You should see an effect of whether the patient has lung disease on conditional inferences about smoking—a person is judged to be substantially more likely to be a smoker if they have lung disease than otherwise—but there are no separate effects of chest pain, shortness of breath, or cough over and above the evidence provided by knowing whether the patient has lung-disease. The intermediate variable lung disease screens off the root cause (smoking) from the more distant effects (coughing, chest pain and shortness of breath).

Here is a concrete example of explaining away in our medical scenario. Having a cold and having lung disease are a priori independent both causally and statistically. But because they are both causes of coughing if we observe `cough` then `cold` and `lung_disease` become statistically dependent. That is, learning something about whether a patient has `cold` or `lung_disease` will, in the presence of their common effect `cough`, convey information about the other condition. `cold` and `lung_disease` are a priori independent, but conditionally dependent given `cough`.

To illustrate, observe how the probabilities of `cold` and `lung_disease` change when we observe `cough` is `true`:
"""

# ╔═╡ be042ac7-93f1-4ab8-9420-fe06ceafa945
viz(randsample(smokes_cond_c_cp_sob_ld, 1000))

# ╔═╡ 40794e8e-53f9-4204-8bda-551b6c51cc7e
ld_and_cold = @joint lung_disease cold

# ╔═╡ ea8fdf94-9de7-4a67-906e-d0024d873f82
ld_and_cold_cond = ld_and_cold |ᶜ cough

# ╔═╡ 6400f767-dcb1-4230-90b9-b6d23066c0fd
cond_cough_samples = randsample(ld_and_cold_cond, 1000)

# ╔═╡ 28be1b57-23ac-4d2f-854c-2d81872b3853
viz(cond_cough_samples)

# ╔═╡ 50ba4c2f-d514-4904-b82c-dc9dfb24a5f2
viz_marginals(cond_cough_samples)

# ╔═╡ 3527c191-c5ab-424c-9bb0-ac3e40377fa1
md"""
Both cold and lung disease are now far more likely than their baseline probability: the probability of having a cold increases from $2\%$ to around $50\%$; the probability of having lung disease also increases from $2.1\%$ to around $50\%$.

Now suppose we also learn that the patient does _not_ have a cold.
"""

# ╔═╡ 9112f40c-09b6-4e29-8d21-8b183026b8d6
cond_cough_not_cold = ld_and_cold |ᶜ (cough &ₚ !ₚ(cold))

# ╔═╡ 2f383a73-2e95-4d0a-adf0-ed80bbb8ec63
cond_cough_not_cold_samples = randsample(cond_cough_not_cold, 1000)

# ╔═╡ 0834861d-e58e-4880-a5c5-26958e295015
viz(cond_cough_not_cold_samples)

# ╔═╡ 364e646e-c951-43ee-a292-268358bbd7b3
viz_marginals(cond_cough_not_cold_samples)

# ╔═╡ f8c9aca8-b4d0-463a-8d7b-837b80ac8734
md"""
The probability of having lung disease increases dramatically. If instead we had observed that the patient does have a cold, the probability of lung cancer returns to its base rate of $2.1\%$
"""

# ╔═╡ cd7b7f8e-8895-415b-88ac-1d72e7285b39
<<<<<<< HEAD
cond_cough_and_cold = ld_and_cold |ᶜ (cough &ₚ cold)

# ╔═╡ 7f797ddf-7d52-4fc9-aa7b-a1659030bc12
cond_cough_cold_samples = randsample(cond_cough_and_cold, 1000)

# ╔═╡ af695d20-321c-4d7e-9d23-7f015e064446
viz(cond_cough_cold_samples)

# ╔═╡ 53d0ed94-a69f-419c-8880-8cc8e162e2bf
viz_marginals(cond_cough_cold_samples)

# ╔═╡ 49c97d61-994c-40d0-a76c-eccabc432fa4
md"""
This is the conditional statistical dependence between lung disease and cold, given cough: Learning that the patient does in fact have a cold “explains away” the observed cough, so the alternative of lung disease decreases to a much lower value — roughly back to its $1$ in a $1000$ rate in the general population. If on the other hand, we had learned that the patient does not have a cold, so the most likely alternative to lung disease is not in fact available to “explain away” the observed cough, which raises the conditional probability of lung disease dramatically. As an exercise, check that if we remove the observation of coughing, the observation of having a cold or not has no influence on our belief about lung disease; this effect is purely conditional on the observation of a common effect of these two causes.
=======
cold_cond_cough_and_cold = cold |ᶜ (cough &ₚ cold)

# ╔═╡ c8c41449-b0bd-4e8a-9fc3-6030900d946a
histogram(randsample(cold_cond_cough_and_cold, 1000), bins = 1)

# ╔═╡ e6b1595e-0ad0-494d-9035-c3c97d7f757b
ld_cond_cough_and_cold = lung_disease |ᶜ (cough &ₚ cold)

# ╔═╡ 36acd72c-6a04-4410-a5dd-630d96a2fc63
histogram(randsample(ld_cond_cough_and_cold, 1000), bins = 1)

# ╔═╡ 49c97d61-994c-40d0-a76c-eccabc432fa4
md"""
This is the conditional statistical dependence between lung disease and cold, given cough: Learning that the patient does in fact have a cold “explains away” the observed cough, so the alternative of lung disease decreases to a much lower value — roughly back to its 1 in a 1000 rate in the general population. If on the other hand, we had learned that the patient does not have a cold, so the most likely alternative to lung disease is not in fact available to “explain away” the observed cough, that raises the conditional probability of lung disease dramatically. As an exercise, check that if we remove the observation of coughing, the observation of having a cold or not has no influence on our belief about lung disease; this effect is purely conditional on the observation of a common effect of these two causes.
>>>>>>> 63fbb76089f4363343026a16775994327da52903

Explaining away effects can be more indirect. Instead of observing the truth value of cold, a direct alternative cause of cough, we might simply observe another symptom that provides evidence for cold, such as fever. Compare these conditions using the above program to see an “explaining away” conditional dependence in belief between `fever` and `lung_disease`.
"""

# ╔═╡ 62e6f8fc-b347-4b1f-992a-02fad6c9de08
md"#### Example: Trait Attribution"

# ╔═╡ 249075ae-9124-4ab5-9cb8-6974df32db97
md"""
A familiar example of rich patterns of inference comes from reasoning about the causes of students’ success and failure in the classroom. Imagine yourself in the position of an interested outside observer—a parent, another teacher, a guidance counselor or college admissions officer—in thinking about these conditional inferences. If a student doesn’t pass an exam, what can you say about why he failed? Maybe he doesn’t do his homework, maybe the exam was unfair, or maybe he was just unlucky?
"""

# ╔═╡ 95fe40b5-3ccf-4a2c-b1f7-a76a0bfe0330
fair_exam = @~ Bernoulli(0.8)

# ╔═╡ 35563ad5-7ed5-4a22-9af1-e52d36499d74
does_homework = @~ Bernoulli(0.8)

<<<<<<< HEAD
# ╔═╡ 73c7cae9-9915-454c-b855-35c20210fc10
function pass_prob(ω) 
	if fair_exam(ω)
		return does_homework(ω) ? 0.9 : 0.4
	else
		return does_homework(ω) ? 0.6 : 0.2
	end
end

# ╔═╡ 0c566edd-f08d-4863-be84-765a015dd999
pass = @~ Bernoulli(pass_prob)
=======
# ╔═╡ 0c566edd-f08d-4863-be84-765a015dd999
pass = @~ Bernoulli(ifelseₚ(fair_exam, ifelseₚ(does_homework, 0.9, 0.4), ifelseₚ(does_homework, 0.6, 0.2)))
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ e74d6024-5111-43b7-a101-3fdf7a417e38
fair_exam_cond_not_pass = fair_exam |ᶜ !ₚ(pass)

# ╔═╡ 44e0070a-0a84-4231-8ecf-64759e033c5b
does_homework_cond_not_pass = does_homework |ᶜ !ₚ(pass)

# ╔═╡ 480bba39-ce0d-4807-a126-86f11ef5b9bb
<<<<<<< HEAD
samples_cond_not_pass =
	randsample((@joint fair_exam_cond_not_pass does_homework_cond_not_pass), 1000)

# ╔═╡ 59f754da-897f-4564-b944-b8230ad3ea8b
viz_marginals(samples_cond_not_pass)

# ╔═╡ 8f69934f-d348-4321-a39d-422e975f0258
viz(samples_cond_not_pass)
=======
barplot(Dict(freqtable(randsample(ω -> (fair_exam_cond_not_pass(ω), does_homework_cond_not_pass(ω)), 1000))), ylabel = "(does_homework, fair_exam)", xlabel = "Frequency")
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ 23b8c71c-a120-4583-aaa6-03ca0fbab36d
md"Now what if you have evidence from several students and several exams? We first re-write the above model to allow many students and exams:"

# ╔═╡ c766e854-33f2-407e-a337-c1479df409ea
fair_exam_m(exam) = exam ~ Bernoulli(0.8)

# ╔═╡ af7ed22e-741e-47bd-8d89-98c1e463c55b
does_homework_m(student) = student ~ Bernoulli(0.8)

# ╔═╡ 2a8f55de-d44d-4ad8-89af-d4787f7b28e7
pass_m(exam, student) = @~ Bernoulli(
	ifelseₚ(fair_exam_m(exam), 
		ifelseₚ(does_homework_m(student), 0.9, 0.4),
		ifelseₚ(does_homework_m(student), 0.6, 0.2)))

# ╔═╡ ea02c349-ecbf-4054-bedf-de5fb5a89b28
begin
	bill = 1
	exam1 = 101
end

# ╔═╡ 99c09e92-c725-473b-998e-9f5c09166715
does_homework_bill(condition) = does_homework_m(bill) |ᶜ condition

# ╔═╡ 4bcdc303-b2cf-4027-9670-71b2ccdb412f
fair_exam_exam1(condition) = fair_exam_m(exam1) |ᶜ condition

<<<<<<< HEAD
# ╔═╡ a1e93444-6777-4d7e-a9a5-e3f380c2e01a
joint(condition) = ω -> (fair_exam_exam1 = fair_exam_exam1(condition)(ω), 
	does_homework_bill = does_homework_bill(condition)(ω))

# ╔═╡ 4189eedc-e757-4edd-8581-114526440dbb
p(condition) = 
	randsample(joint(condition), 1000)
=======
# ╔═╡ 4189eedc-e757-4edd-8581-114526440dbb
p(condition) = Dict(freqtable(randsample(ω -> (fair_exam_exam1(condition)(ω), does_homework_bill(condition)(ω)), 1000)))
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ 15bc136b-7d4d-4aae-b748-916e4fc03e04
c = !ₚ(pass_m(exam1, bill))

<<<<<<< HEAD
# ╔═╡ f566cdd4-e4f9-4851-ae1d-d2905d78f97a
viz(p(c))

# ╔═╡ 8008a8d8-75c8-4ff6-a86e-c32c4c13d80f
viz_marginals(p(c))
=======
# ╔═╡ a20ed174-9487-46b7-92ac-13a65604fb29
barplot(p(c), ylabel = "(does_homework(Bill), fair_exam(Exam1))", xlabel = "Frequency")
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ 1d0db992-a354-4544-9120-069e99352ee2
md"""
Initially we observe that Bill failed exam 1. A priori, we assume that most students do their homework and most exams are fair, but given this one observation it becomes somewhat likely that either the student didn’t study or the exam was unfair.

Notice that we have set the probabilities in the pass function to be asymmetric: whether a student does homework has a greater influence on passing the test than whether the exam is fair. This in turns means that when inferring the cause of a failed exam, the model tends to attribute it to the person property (not doing homework) over the situation property (exam being unfair). This asymmetry is an example of the _fundamental attribution bias_ ([Ross, 1977](https://scholar.google.com/scholar?q=%22The%20intuitive%20psychologist%20and%20his%20shortcomings%3A%20Distortions%20in%20the%20attribution%20process%22)): we tend to attribute outcomes to personal traits rather than situations. However there are many interacting tendencies (for instance the direction of this bias switches for members of some east-asian cultures). How could you extend the model to account for these interactions?

See how conditional inferences about Bill and exam 1 change as you add in more data about this student or this exam, or additional students and exams.
"""

# ╔═╡ 9eb80385-0ba2-4098-9f69-90c5dba05401
c1 = !ₚ(pass_m(exam1, bill)) &ₚ !ₚ(pass_m(bill, 102))

# ╔═╡ 75615669-497e-4f95-a358-1f6c2f233bf6
<<<<<<< HEAD
viz(p(c1))

# ╔═╡ f06b4818-395a-42dc-a923-000ef053d53c
viz_marginals(p(c1))
=======
barplot(p(c1), ylabel = "(does_homework(Bill), fair_exam(Exam1))", xlabel = "Frequency")
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ 49a11937-3893-476e-b618-efd713903589
md"""
Try using each of the below expressions as the condition (`c1`) for the above inference. Try to explain the different inferences that result at each stage. What does each new piece of the larger data set contribute to your intuition about Bill and exam 1?
"""

# ╔═╡ b91191aa-b121-42c2-aac1-67c94923d287
md"""
* `pw(&, !ₚ(pass_m(bill, exam1)), !ₚ(pass_m(2, exam1)), !ₚ(pass_m(3, exam1)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), !ₚ(pass_m(bill, 102)), !ₚ(pass_m(2, exam1)), !ₚ(pass_m(3, exam1)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), !ₚ(pass_m(2, exam1)), (pass_m(2, 102)), (pass_m(2, 103)), (pass_m(2, 104)), (pass_m(2, 105)), !ₚ(pass_m(3, exam1)), (pass_m(3, 102)), (pass_m(3, 103)), (pass_m(3, 104)), (pass_m(3, 105)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), (pass_m(2, exam1)), (pass_m(3, exam1)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), (pass_m(2, exam1)), (pass_m(2, 102)), (pass_m(2, 103)), (pass_m(2, 104)), (pass_m(2, 105)), (pass_m(3, exam1)), (pass_m(3, 102)), (pass_m(3, 103)), (pass_m(3, 104)), (pass_m(3, 105)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), !ₚ(pass_m(bill, 102)), (pass_m(2, exam1)), (pass_m(2, 102)), (pass_m(2, 103)), (pass_m(2, 104)), (pass_m(2, 105)), (pass_m(3, exam1)), (pass_m(3, 102)), (pass_m(3, 103)), (pass_m(3, 104)), (pass_m(3, 105)))`

* `pw(&, !ₚ(pass_m(bill, exam1)), !ₚ(pass_m(bill, 102)), (pass_m(bill, 103)), (pass_m(bill, 104)), (pass_m(bill, 105)), (pass_m(2, exam1)), (pass_m(2, 102)), (pass_m(2, 103)), (pass_m(2, 104)), (pass_m(2, 105)), (pass_m(3, exam1)), (pass_m(3, 102)), (pass_m(3, 103)), (pass_m(3, 104)), (pass_m(3, 105)))`
"""

# ╔═╡ fd21ac96-dff2-4645-b3f4-e2dc2aaabc96
md"""
This example is inspired by the work of Harold Kelley (and many others) on causal attribution in social settings ([Kelley, 1973](https://scholar.google.com/scholar?q=%22The%20processes%20of%20causal%20attribution.%22)). Kelley identified three important dimensions of variation in the evidence, which affect the attributions people make of the cause of an outcome. These three dimensions are: Persons—is the outcome consistent across different people in the situation?; Entities—is the outcome consistent for different entities in the situation?; Time—is the outcome consistent over different episodes? These dimensions map onto the different sets of evidence we have just seen.

As in this example, people often have to make inferences about entities and their interactions. Such problems tend to have dense relations between the entities, leading to very challenging explaining away problems. These inferences often come very naturally to people, yet they are computationally difficult. Perhaps these are important problems that our brains have specialized somewhat to solve, or perhaps that they have evolved general solutions to these tough inferences.
"""

# ╔═╡ 367a8332-d896-4cb9-bd91-18c81c326611
md"#### Example: Of Blickets and Blocking"

# ╔═╡ e9fa5596-d519-471e-aeee-47147fcd3288
md"""
A number of researchers have explored children’s causal learning abilities by using the “blicket detector” ([Gopnik and Sobel, 2000](https://scholar.google.com/scholar?q=%22Detecting%20blickets%3A%20How%20young%20children%20use%20information%20about%20novel%20causal%20powers%20in%20categorization%20and%20induction%22)): a toy box that will light up when certain blocks, the blickets, are put on top of it. Children are shown a set of evidence and then asked which blocks are blickets. For instance, if block $A$ makes the detector go off, it is probably a blicket. Ambiguous patterns are particularly interesting. Imagine that blocks $A$ and $B$ are put on the detector together, making the detector go off; it is fairly likely that $A$ is a blicket. Now $B$ is put on the detector alone, making the detector go off; it is now less plausible that $A$ is a blicket. This is called “backward blocking”, and it is an example of explaining away.

We can capture this set up with a model in which each block has a persistent “blicket-ness” property, and the causal power of the block to make the machine go off depends on its blicketness. Finally, the machine goes off if any of the blocks on it is a blicket (but noisily).
"""

# ╔═╡ 60ff06d3-476d-4ac4-8e7d-6ae33d3814e8
blicket(block) = block ~ Bernoulli(0.4)

# ╔═╡ afa9c257-ad3c-45f5-b8ed-d9f62c9b3804
power(block) = ifelseₚ(blicket(block), 0.9, 0.05)

# ╔═╡ 2d19b551-2c62-4e5a-9212-1cf6dfe06317
function machine(blocks)
	if isempty(blocks)
		return @~ Bernoulli(0.05)
	else
		return (@~ Bernoulli(power(blocks[1]))) |ₚ machine(blocks[2:end])
	end
end

# ╔═╡ d0031457-3a36-4bb9-9263-00eaad7e4f43
blicket_cond = blicket(1) |ᶜ machine([1, 2])

# ╔═╡ f4aa162d-9ff7-4db2-94d6-98c85da8a395
<<<<<<< HEAD
viz(randsample(blicket_cond, 1000))
=======
histogram(randsample(blicket_cond, 1000), bins = 1)
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ a0afd23b-636e-4a62-a242-07e1480f7d72
md"The backward blocking scenario described above:"

# ╔═╡ 8981dd2a-3d8d-43e2-b504-72352d69cb1c
<<<<<<< HEAD
viz(randsample(blicket(1) |ᶜ machine([2]), 1000))
=======
histogram(randsample(blicket(1) |ᶜ machine([2]), 1000), bins = 1)
>>>>>>> 63fbb76089f4363343026a16775994327da52903

# ╔═╡ beb0f49a-03b9-496c-abf3-f32b6d37766f
md"[Sobel et al. (2004)](https://scholar.google.com/scholar?q=%22Children%27s%20causal%20inferences%20from%20indirect%20evidence%3A%20Backwards%20blocking%20and%20Bayesian%20reasoning%20in%20preschoolers%22) tried this with children, finding that four year-olds perform similarly to the model: evidence that $B$ is a blicket explains away the evidence that $A$ and $B$ made the detector go away."

# ╔═╡ Cell order:
# ╠═a6793602-5caa-11ec-1047-f9c7ee843ccf
<<<<<<< HEAD
# ╠═e32ccfe6-d204-4e2c-835f-d207a00575d4
=======
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╟─7b2999d0-e66b-4212-be30-3be990be04f9
# ╟─68841072-3016-4de8-9fad-3d4d8be3fc5b
# ╟─5c2d0805-2039-4c42-9b86-17216dab9319
# ╟─346f4f4a-23ff-4ede-b95f-14b257bbaf8b
# ╟─035aa787-f941-43e4-937e-accefbb7498c
# ╠═34d232f9-a8bb-47ad-82e6-9280fd0bca98
<<<<<<< HEAD
=======
# ╠═c2242a03-c976-4454-8be3-4cd2b27adc50
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╠═64335ca1-48a9-435d-93f5-c71adfa71677
# ╠═7d51eedb-d042-446f-a2f7-da7c4b3e58c2
# ╠═e6481a46-550d-443d-b4f7-9ad961a1e957
# ╟─5e308604-38b3-4411-8adc-096a55e2963a
# ╠═f002b30b-ad9d-4bc8-b38e-cc1fcb7bbc62
# ╟─58c19d66-48a2-491a-9651-8b5340c4b4f8
# ╠═0e70a11d-a3d9-473a-9bcc-666d02fe56c8
# ╟─c17a0aa6-8991-4798-b478-899859a4123c
# ╟─150914fd-47a5-4d70-aec7-4ab361b44aee
# ╟─c55b478b-737f-4b31-a90c-dec9659dfe06
# ╟─2ab4bdcc-6300-4911-a96c-a8d71a6e7a66
# ╠═6a911b82-abd4-4fb3-890d-83575a23c514
# ╠═8a779fe1-fe21-428d-8d1e-0598e8c53e14
# ╠═48ebe872-8c2f-477f-b09a-2c91725f590a
# ╠═39496d8b-5b75-459a-b004-a6a7e3f06213
# ╟─8b641417-3699-48fd-b946-94285d0359c7
# ╠═e54f25e2-1f02-4b33-a033-4f9d5fc855ef
# ╟─4613124b-2ff9-46a5-8740-691730b55684
# ╠═54087a09-3774-472a-987e-a67f691a9d65
# ╟─8b154a12-b15a-4fea-83ea-2b43af19e03d
# ╟─93bb0b08-3cfe-429b-840f-e2628005fc84
# ╠═099a9976-611d-4d0a-9e7e-e1a505df3a9a
# ╠═b3c69b87-405f-4cef-ba52-d0986328f739
# ╠═dc660eb9-2868-4773-8387-195133311851
# ╠═82bb2560-4003-4651-9859-ecfa664e7a22
# ╠═72fb2dc6-b89f-4bec-a00f-a09cdc19bfa3
# ╠═998e9e30-af54-4ced-afb2-44e9ca5c10e1
# ╟─781d2a73-7060-42b2-9db0-ea0c5da76f68
# ╠═3e717d2c-ba8e-4331-87d6-e2232bedb5eb
# ╠═14de8534-62d2-4051-b590-403f80ab4c77
# ╠═b5be4e3e-be2a-41f8-9038-773eda8b8073
# ╟─f6bc26c5-ff48-48b1-b98e-9ea64df1f6f2
# ╟─c9e9ac6c-a2ce-45e2-8c65-c8815b65f692
<<<<<<< HEAD
# ╟─71e44172-66f8-4989-aca6-bf1ef3964122
# ╟─f406a180-150f-47f2-a8b0-1d918738e3ec
# ╟─2b360158-08f5-46d2-98d8-10e764de554c
=======
# ╟─f406a180-150f-47f2-a8b0-1d918738e3ec
# ╟─2b360158-08f5-46d2-98d8-10e764de554c
# ╟─71e44172-66f8-4989-aca6-bf1ef3964122
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╠═a2bf38d2-edc8-410f-8a3f-ec80f1bc9376
# ╠═384aa2e3-c9be-4014-bac0-91adeb50a92d
# ╠═b442387a-f1c3-4437-a7c3-4b4115625d83
# ╠═a5b4825b-7df0-44ca-b5c0-29da7c9b7e94
# ╠═58d05c77-4593-4ef3-bc81-4213bbb63def
# ╠═32954a31-6e3f-4689-8c9f-942553315845
# ╠═55beb01c-7598-4c54-8264-559dac01a197
# ╠═885ea696-dda5-40cb-879e-47e293d0fde6
# ╠═370c6749-de71-4783-a831-02b8c692181b
# ╟─7e98268f-81c5-4e63-9f34-7af0f75f415e
# ╠═30b6fb25-2c81-4975-bc52-1c31ce79047b
# ╟─7cd38ff5-e93b-4ad4-ac94-4b1b2042a063
# ╠═be042ac7-93f1-4ab8-9420-fe06ceafa945
# ╠═40794e8e-53f9-4204-8bda-551b6c51cc7e
<<<<<<< HEAD
# ╠═ea8fdf94-9de7-4a67-906e-d0024d873f82
# ╠═6400f767-dcb1-4230-90b9-b6d23066c0fd
# ╠═28be1b57-23ac-4d2f-854c-2d81872b3853
# ╠═50ba4c2f-d514-4904-b82c-dc9dfb24a5f2
# ╟─3527c191-c5ab-424c-9bb0-ac3e40377fa1
# ╠═9112f40c-09b6-4e29-8d21-8b183026b8d6
# ╠═2f383a73-2e95-4d0a-adf0-ed80bbb8ec63
# ╠═0834861d-e58e-4880-a5c5-26958e295015
# ╠═364e646e-c951-43ee-a292-268358bbd7b3
# ╟─f8c9aca8-b4d0-463a-8d7b-837b80ac8734
# ╠═cd7b7f8e-8895-415b-88ac-1d72e7285b39
# ╠═7f797ddf-7d52-4fc9-aa7b-a1659030bc12
# ╠═af695d20-321c-4d7e-9d23-7f015e064446
# ╠═53d0ed94-a69f-419c-8880-8cc8e162e2bf
=======
# ╠═6400f767-dcb1-4230-90b9-b6d23066c0fd
# ╠═a2c8cc36-e109-45ea-9c8b-d579e3d183b3
# ╠═c4dff21e-d179-4d1c-8eac-d922b8316f42
# ╟─3527c191-c5ab-424c-9bb0-ac3e40377fa1
# ╠═9112f40c-09b6-4e29-8d21-8b183026b8d6
# ╠═0834861d-e58e-4880-a5c5-26958e295015
# ╠═9ec9ee39-3925-4e38-8af9-cf4451011626
# ╠═364e646e-c951-43ee-a292-268358bbd7b3
# ╟─f8c9aca8-b4d0-463a-8d7b-837b80ac8734
# ╠═cd7b7f8e-8895-415b-88ac-1d72e7285b39
# ╠═c8c41449-b0bd-4e8a-9fc3-6030900d946a
# ╠═e6b1595e-0ad0-494d-9035-c3c97d7f757b
# ╠═36acd72c-6a04-4410-a5dd-630d96a2fc63
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╟─49c97d61-994c-40d0-a76c-eccabc432fa4
# ╟─62e6f8fc-b347-4b1f-992a-02fad6c9de08
# ╟─249075ae-9124-4ab5-9cb8-6974df32db97
# ╠═95fe40b5-3ccf-4a2c-b1f7-a76a0bfe0330
# ╠═35563ad5-7ed5-4a22-9af1-e52d36499d74
<<<<<<< HEAD
# ╠═73c7cae9-9915-454c-b855-35c20210fc10
=======
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╠═0c566edd-f08d-4863-be84-765a015dd999
# ╠═e74d6024-5111-43b7-a101-3fdf7a417e38
# ╠═44e0070a-0a84-4231-8ecf-64759e033c5b
# ╠═480bba39-ce0d-4807-a126-86f11ef5b9bb
<<<<<<< HEAD
# ╠═59f754da-897f-4564-b944-b8230ad3ea8b
# ╠═8f69934f-d348-4321-a39d-422e975f0258
=======
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╟─23b8c71c-a120-4583-aaa6-03ca0fbab36d
# ╠═c766e854-33f2-407e-a337-c1479df409ea
# ╠═af7ed22e-741e-47bd-8d89-98c1e463c55b
# ╠═2a8f55de-d44d-4ad8-89af-d4787f7b28e7
# ╠═ea02c349-ecbf-4054-bedf-de5fb5a89b28
# ╠═99c09e92-c725-473b-998e-9f5c09166715
# ╠═4bcdc303-b2cf-4027-9670-71b2ccdb412f
<<<<<<< HEAD
# ╠═a1e93444-6777-4d7e-a9a5-e3f380c2e01a
# ╠═4189eedc-e757-4edd-8581-114526440dbb
# ╠═15bc136b-7d4d-4aae-b748-916e4fc03e04
# ╠═f566cdd4-e4f9-4851-ae1d-d2905d78f97a
# ╠═8008a8d8-75c8-4ff6-a86e-c32c4c13d80f
# ╟─1d0db992-a354-4544-9120-069e99352ee2
# ╠═9eb80385-0ba2-4098-9f69-90c5dba05401
# ╠═75615669-497e-4f95-a358-1f6c2f233bf6
# ╠═f06b4818-395a-42dc-a923-000ef053d53c
=======
# ╠═4189eedc-e757-4edd-8581-114526440dbb
# ╠═15bc136b-7d4d-4aae-b748-916e4fc03e04
# ╠═a20ed174-9487-46b7-92ac-13a65604fb29
# ╟─1d0db992-a354-4544-9120-069e99352ee2
# ╠═9eb80385-0ba2-4098-9f69-90c5dba05401
# ╠═75615669-497e-4f95-a358-1f6c2f233bf6
>>>>>>> 63fbb76089f4363343026a16775994327da52903
# ╟─49a11937-3893-476e-b618-efd713903589
# ╟─b91191aa-b121-42c2-aac1-67c94923d287
# ╟─fd21ac96-dff2-4645-b3f4-e2dc2aaabc96
# ╟─367a8332-d896-4cb9-bd91-18c81c326611
# ╟─e9fa5596-d519-471e-aeee-47147fcd3288
# ╠═60ff06d3-476d-4ac4-8e7d-6ae33d3814e8
# ╠═afa9c257-ad3c-45f5-b8ed-d9f62c9b3804
# ╠═2d19b551-2c62-4e5a-9212-1cf6dfe06317
# ╠═d0031457-3a36-4bb9-9263-00eaad7e4f43
# ╠═f4aa162d-9ff7-4db2-94d6-98c85da8a395
# ╟─a0afd23b-636e-4a62-a242-07e1480f7d72
# ╠═8981dd2a-3d8d-43e2-b504-72352d69cb1c
# ╟─beb0f49a-03b9-496c-abf3-f32b6d37766f

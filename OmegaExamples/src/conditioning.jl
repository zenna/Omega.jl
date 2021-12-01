### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ f532f3b0-5293-11ec-104c-dba9836ec3d1
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots
end

# ╔═╡ 711c87ea-9ec0-4957-bc00-641e2dd6eaec
md"## Cognition and conditioning"

# ╔═╡ 877ff248-596c-4755-8085-281d1752ec5b
md"We have built up a tool set for constructing probabilistic generative models. These can represent knowledge about causal processes in the world: running one of these programs generates a particular outcome by sampling a “history” for that outcome. However, the power of a causal model lies in the flexible ways it can be used to reason about the world. In the last chapter we ran generative models forward to reason about outcomes from initial conditions. Generative models also enable reasoning in other ways. For instance, if we have a generative model in which X is the output of a process that depends on Y (say `X = coolFunction(Y)`) we may ask: “assuming I have observed a certain X, what must Y have been?” That is we can reason backward from outcomes to initial conditions. More generally, we can make hypothetical assumptions and reason about the generative history: “assuming something, how did the generative model run?” In this section we describe how a wide variety of such hypothetical inferences can be made from a single generative model by conditioning the model on an assumed or observed fact."

# ╔═╡ a0d93e64-92ca-4d32-905f-b99e5f3780d5
md"Much of cognition can be understood in terms of conditional inference. In its most basic form, causal attribution is conditional inference: given some observed effects, what were the likely causes? Predictions are conditional inferences in the opposite direction: given that I have observed some cause, what are its likely effects? These inferences can be described by conditioning a probabilistic program that expresses a causal model. The acquisition of that causal model, or learning, is also conditional inference at a higher level of abstraction: given our general knowledge of how causal relations operate in the world, and some observed events in which candidate causes and effects co-occur in various ways, what specific causal relations are likely to hold between these observed variables?"

# ╔═╡ 2a4caee4-f64a-4f2d-9b82-44df111c2c8b
md"To see how the same concepts apply in a domain that is not usually thought of as causal, consider language. The core questions of interest in the study of natural language are all at heart conditional inference problems. Given beliefs about the structure of my language, and an observed sentence, what should I believe about the syntactic structure of that sentence? This is the parsing problem. The complementary problem of speech production is related: given the structure of my language (and beliefs about others’ beliefs about that), and a particular thought I want to express, how should I encode the thought? Finally, the acquisition problem: given some data from a particular language, and perhaps general knowledge about universals of grammar, what should we believe about that language’s structure? This problem is simultaneously the problem facing the linguist and the child trying to learn a language."

# ╔═╡ 59f09e31-aa76-4b73-b841-e6192841060e
md"Parallel problems of conditional inference arise in visual perception, social cognition, and virtually every other domain of cognition. In visual perception, we observe an image or image sequence that is the result of rendering a three-dimensional physical scene onto our two-dimensional retinas. A probabilistic program can model both the physical processes at work in the world that produce natural scenes, and the imaging processes (the “graphics”) that generate images from scenes. Perception can then be seen as conditioning this program on some observed output image and inferring the scenes most likely to have given rise to it."

# ╔═╡ bbbac3fa-3708-4d4e-87e1-01143a1b3eb0
md"When interacting with other people, we observe their actions, which result from a planning process, and often want to guess their desires, beliefs, emotions, or future actions. Planning can be modeled as a program that takes as input an agent’s mental states (beliefs, desires, etc.) and produces action sequences—for a rational agent, these will be actions that are likely to produce the agent’s desired states reliably and efficiently. A rational agent can plan their actions by conditional inference to infer what steps would be most likely to achieve their desired state. Action understanding, or interpreting an agent’s observed behavior, can be expressed as conditioning a planning program (a “theory of mind”) on observed actions to infer the mental states that most likely gave rise to those actions, and to predict how the agent is likely to act in the future."

# ╔═╡ 60be7683-0b4c-467b-ba72-4d687bff9a1b
md"## Hypothetical Reasoning"

# ╔═╡ bcfd08bc-91f6-4745-aeb0-9e7ecd218388


# ╔═╡ Cell order:
# ╠═f532f3b0-5293-11ec-104c-dba9836ec3d1
# ╟─711c87ea-9ec0-4957-bc00-641e2dd6eaec
# ╟─877ff248-596c-4755-8085-281d1752ec5b
# ╟─a0d93e64-92ca-4d32-905f-b99e5f3780d5
# ╟─2a4caee4-f64a-4f2d-9b82-44df111c2c8b
# ╟─59f09e31-aa76-4b73-b841-e6192841060e
# ╟─bbbac3fa-3708-4d4e-87e1-01143a1b3eb0
# ╟─60be7683-0b4c-467b-ba72-4d687bff9a1b
# ╠═bcfd08bc-91f6-4745-aeb0-9e7ecd218388

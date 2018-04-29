var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Mu.jl-1",
    "page": "Home",
    "title": "Mu.jl",
    "category": "section",
    "text": "Mu.jl is a small programming language for causal and probabilistic reasoning."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Mu is built in Julia but not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with:Pkg.clone(\"https://github.com/zenna/Mu.jl.git\")"
},

{
    "location": "started.html#",
    "page": "Getting started",
    "title": "Getting started",
    "category": "page",
    "text": ""
},

{
    "location": "started.html#Selection-1",
    "page": "Getting started",
    "title": "Selection",
    "category": "section",
    "text": "Arrows has a few mechanisms to select Ports, SubPorts and various Arrow types. Arrows.jl embraces unicode! The following symbols are used throughout:▸ = in_port\n◂ = out_port\n▹ = in_sub_port\n◃ = out_sub_port\n⬧ = port\n⬨ = sub_port"
},

{
    "location": "started.html#Filtering-Examples-1",
    "page": "Getting started",
    "title": "Filtering Examples",
    "category": "section",
    "text": "These can be used to select filtering by boolean combinations of predicates◂(arr, 1): The first out Port\n▹(sarr, is(θp)): all parametric in SubPorts\n◂(carr, is(ϵ) ∨ is(θp), 1:3): first 3 Ports which are error or parametric"
},

]}

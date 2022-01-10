using Documenter, SoftPredicates

makedocs(;
    modules=[SoftPredicates],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/zenna/SoftPredicates.jl/blob/{commit}{path}#L{line}",
    sitename="SoftPredicates.jl",
    authors="Zenna Tavares",
    assets=String[],
)

deploydocs(;
    repo="github.com/zenna/SoftPredicates.jl",
)

using AcronymGenerator
using Documenter

makedocs(;
    modules=[AcronymGenerator],
    authors="Jared Lumpe",
    repo="https://github.com/jlumpe/AcronymGenerator.jl/blob/{commit}{path}#L{line}",
    sitename="AcronymGenerator.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

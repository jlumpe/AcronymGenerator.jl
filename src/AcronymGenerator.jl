module AcronymGenerator

export Acronym, AcronymFamily, ScoreParams, ScoredAcronymFamily
export generate_acronyms, acronyms, score, best_acronym, generate_prefix_map


include("util.jl")
include("acronym.jl")
include("score.jl")
include("findbest.jl")
include("display.jl")

end

struct ScoreParams
    word_groups::Vector{Vector{String}}
    group_scores::Vector{Float64}
    required_groups::Vector{Int}
    gap_penalty::Float64
    normalize::Bool
    word_to_group::Dict{String, Int}
    
    function ScoreParams(word_groups, group_scores, required_groups, gap_penalty; normalize=false)
        word_to_group = Dict(word => i for (i, words) in enumerate(word_groups) for word in words)
        return new(word_groups, group_scores, required_groups, gap_penalty, normalize, word_to_group)
    end
end


function ScoreParams(pairs::AbstractVector{<:Pair}, gap_penalty::Real; normalize=false)
    word_groups = Vector{String}[]
    group_scores = Float64[]
    required_groups = Int[]
    
    for (i, (words, score)) in enumerate(pairs)
        push!(word_groups, words)
        if score == Inf
            push!(group_scores, 0.)
            push!(required_groups, i)
        else
            push!(group_scores, score)
        end
    end
    
    return ScoreParams(word_groups, group_scores, required_groups, gap_penalty; normalize=normalize)
end


function score(components, params::ScoreParams)
    group_seen = falses(length(params.word_groups))
    s = 0.
    
    for word in components
        g = get(params.word_to_group, word, 0)
        if g > 0
            if !group_seen[g]
                s += params.group_scores[g]
                group_seen[g] = true
            end
        else
            s -= params.gap_penalty
        end
    end

    params.normalize && (s /= length(components))
    
    return all(group_seen[i] for i in params.required_groups) ? s : -Inf
end


score(a::Acronym, params::ScoreParams) = score(a.components, params)

function score_word(word::String, params::ScoreParams)
    g = params.word_to_group[word]
    return g == 0 ? -params.gap_penalty : params.group_scores[g]
end


struct ScoredAcronymFamily
    family::AcronymFamily
    params::ScoreParams
    best::Acronym
    best_score::Float64
    
    ScoredAcronymFamily(family, params, best) = new(family, params, best, score(best, params))
    ScoredAcronymFamily(family, params) = new(family, params, best_acronym(family, params)...)
end
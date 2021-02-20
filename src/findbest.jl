
abstract type FindBestAlg end
struct BruteForce <: FindBestAlg end
struct MaybeFaster <: FindBestAlg end


best_acronym(af::AcronymFamily, params::ScoreParams) = best_acronym(BruteForce(), af, params)

best_acronym(::BruteForce, af::AcronymFamily, params::ScoreParams) = maximum_by(last, (a, score(a, params)) for a in acronyms(af))


best_acronym(::MaybeFaster, af::AcronymFamily, params::ScoreParams) = maximum_by(last, _best_faster(af, trace, params) for trace in _family_traces(af))

function _best_faster(af::AcronymFamily, trace::AbstractVector{NTuple{2, Int}}, params::ScoreParams)
    ac_words = Union{String, Nothing}[]
    s = 0.
    group_seen = falses(length(params.word_groups))
    
    for (i, n) in trace
        words = af.components[n, i]
        
        if isempty(words)
            push!(ac_words, nothing)
            s -= params.gap_penalty
            
        else
            best_word = nothing
            best_score = -Inf
            
            for word in words
                g = params.word_to_group[word]
                ws = params.group_scores[g]
                
                if g in params.required_groups && !group_seen[g]
                    best_word = word
                    best_score = 0.
                    break
                elseif ws > best_score
                    best_word = word
                    best_score = ws
                end
            end
            
            push!(ac_words, best_word)
            s += best_score
            group_seen[params.word_to_group[best_word]] = true
        end
    end
    
    all(group_seen[g] for g in params.required_groups) || (s = -Inf)
    
    a = Acronym(af.word, ac_words, last.(trace))
    return a, s
end
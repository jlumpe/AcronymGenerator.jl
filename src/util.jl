splitword(s::AbstractString, n::Int) = (s[1:n], s[(n+1):end])


function generate_prefix_map(nmax::Int, words)
    prefix_map = Dict{String, Vector{String}}()

    for word in words
        for n in 1:min(nmax, length(word))
            prefix = word[1:n]
            a = get!(prefix_map, prefix, String[])
            push!(a, word)
        end
    end
    
    return prefix_map
end


function maximum_by(by, itr)
    maxv, rest = Iterators.peel(itr)
    maxb = by(maxv)
    
    for v in rest
        b = by(v)
        if isless(maxb, b)
            maxv = v
            maxb = b
        end
    end
    
    return maxv
end
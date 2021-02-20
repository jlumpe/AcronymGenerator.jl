struct Acronym
    word::String
    components::Vector{Union{String, Nothing}}
    nvals::Vector{Int}
end


struct AcronymFamily
    word::String
    n_max::Int
    components::Matrix{Vector{String}}
end


Base.show(io::IO, af::AcronymFamily) = print(io, typeof(af), "(\"", af.word, "\", ", af.n_max, ", ...)")


function _family_traces(af::AcronymFamily)
    max_n, l = size(af.components)
    a = [Vector{Tuple{Int, Int}}[] for _ in af.components]
    
    for i in l:-1:1, n in 1:max_n
        n > 1 && isempty(af.components[n, i]) && continue  # No components
        
        ind = (i, n)
        next = i + n
        
        if next == l + 1  # Last
            push!(a[n, i], [ind])
            
        elseif next <= l
            for nexttraces in a[:, next]
                for nexttrace in nexttraces
                    push!(a[n, i], vcat(ind, nexttrace))
                end
            end
        end
        
    end
    
    return vcat(a[:, 1]...)
end


function acronyms(af::AcronymFamily, trace::AbstractVector{NTuple{2, Int}})
    comp_lists = [af.components[n, i] for (i, n) in trace]
    nvals = last.(trace)
    comps_iter = Iterators.product((isempty(c) ? [nothing] : c for c in comp_lists)...)
    return (Acronym(af.word, collect(comp), nvals) for comp in comps_iter)
end


acronyms(af::AcronymFamily) = Iterators.flatten(acronyms(af, trace) for trace in _family_traces(af))


function generate_acronyms(word::String, max_n::Int, prefix_map::Dict)
    word = lowercase(word)
    l = length(word)
    
    components = Matrix{Vector{String}}(undef, max_n, l)
    
    for i in 1:l
        for j in 1:max_n
            if i + j - 1 > l
                components[j, i] = String[]
            
            else
                prefix = word[i:(i + j - 1)]
                components[j, i] = get(prefix_map, prefix, String[])
            end
        end
    end
    
    return AcronymFamily(word, max_n, components)
end

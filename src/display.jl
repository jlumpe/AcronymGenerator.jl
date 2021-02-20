function _show_acronym_component_html(io::IO, c::String, n::Int)
    a, b = splitword(c, n)
    print(io, "<strong>", uppercase(a), "</strong>", b)
end


function Base.show(io::IO, ::MIME"text/html", a::Acronym)
    p = 1
    for (i, (comp, n)) in enumerate(zip(a.components, a.nvals))
        if isnothing(comp)
            comp2 = a.word[p:(p+n-1)]
            _show_acronym_component_html(io, comp2, n)
            print(io, "???")
        else
            _show_acronym_component_html(io, comp, n)
        end
        i != length(a.components) && print(io, " ")
        
        p += n
    end
end


function Base.show(io::IO, ::MIME"text/html", af::AcronymFamily)
    println(io, "<table class=\"acronym\">")
    
    println(io, "<thead>")
    print(io, "<tr>")
    for letter in af.word
        print(io, "<th>", uppercase(letter), "</th>")
    end
    print(io, "</tr>")
    println(io, "</thead>")
    
    
    println(io, "<tbody>")
    for (i, row) in enumerate(eachrow(af.components))
        println(io, "<tr>")
        
        for words in row
            println(io, "<td>")
            
            isempty(words) && print(io, "?")
            
            for word in words
                _show_acronym_component_html(io, word, i)
                print(io, " <br> ")
            end
            
            println(io, "</td>")
        end
        
        println(io, "</tr>")
    end
    println(io, "</tbody>")
    
    println(io, "</table>")
end


function Base.show(io::IO, ::MIME"text/html", saf::ScoredAcronymFamily)
    af = saf.family
    l = size(af.components, 2)
    
    println(io, "<table class=\"acronym\">")
    
    println(io, "<thead>")
    
    print(io, "<tr>")
    print(io, "<th colspan=$(l-1)>", uppercase(af.word), "</th>")
    println(io, "<th>", saf.best_score, "</th>")
    println(io, "</tr>")
    
    print(io, "<tr>")
    for letter in af.word
        print(io, "<th>", uppercase(letter), "</th>")
    end
    println(io, "</tr>")
    
    println(io, "</thead>")
    
    println(io, "<tbody>")
    for (i, row) in enumerate(eachrow(af.components))
        println(io, "<tr>")
        
        for words in row
            println(io, "<td>")
            
            isempty(words) && println(io, "?")
            
            for word in sort(words, by=word -> score_word(word, saf.params), rev=true)
                _show_acronym_component_html(io, word, i)
                print(io, " <br> ")
            end
            
            println(io, "</td>")
        end
        
        println(io, "</tr>")
    end
    println(io, "</tbody>")
    
    println(io, "</table>")
end
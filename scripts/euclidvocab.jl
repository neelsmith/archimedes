f =  joinpath(pwd(), "texts", "euclid-words.txt")
@assert isfile(f)

txtraw = read(f, String)
txt1 = replace(txtraw, "·" => ":")
txt = replace(txt1, r"-[ ]*" => "")

using Orthography, PolytonicGreek
tkns = tokenize(txt, literaryGreek())


"""True if string `s` parses as a label."""
function islabel(s)
    allcaps = true
    for c in s
        if islowercase(c) || Base.Unicode.category_string(c) == "Punctuation, other" || s[end] == 'ʹ'
            allcaps = false
        end
    end
    allcaps
end

"""True if final character of `s` is numeric marker."""
function isnum(s)
    s[end] == 'ʹ'
end


lookslikelex = filter(tkns) do t
    (t.tokencategory isa PunctuationToken) == false && isnum(t.text) == false
end

tknstrings = map(lookslikelex) do tkn
    tkn.text
end




using StatsBase, OrderedCollections

counts = countmap(tknstrings) |> OrderedDict
sorted = sort(counts, byvalue=true, rev=true)


delimited = ["token|count"]
for k in keys(sorted)
    push!(delimited, string(k,"|", sorted[k]))
end

outfile = joinpath(pwd(), "data", "euclid-rawtokencounts.cex")
open(outfile, "w") do io
    write(io, join(delimited,"\n"))
end




using Kanones
nolabels = filter(tkns) do t
    (t.tokencategory isa PunctuationToken) == false && ! islabel(t.text) && ! isnum(t.text)
end



lctokens = map(t -> knormal(t.text), nolabels)

lccounts = countmap(lctokens) |> OrderedDict
lcsorted = sort(lccounts, byvalue=true, rev=true)


lcdelimited = ["token|count"]
for k in keys(lcsorted)
    push!(lcdelimited, string(k,"|", lcsorted[k]))
end

lcoutfile = joinpath(pwd(), "data", "euclid-tokensnormed.cex")
open(lcoutfile, "w") do io
    write(io, join(lcdelimited,"\n"))
end


wordlistfile = joinpath(pwd(), "data", "euclid-wordlist-ordered.txt")
wordlist = collect(keys(lcsorted))
open(wordlistfile,"w") do io
    write(io, join(wordlist, "\n") )
end
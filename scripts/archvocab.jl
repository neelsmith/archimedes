f = joinpath(pwd(), "SandC-src.txt")
outfile = "tokencounts-sandc.cex"
#f = joinpath(pwd(), "archimedes-src.txt")
#outfile = "tokencounts-all.cex"
srclines = readlines(f)

parts = map(srclines) do ln
    split(ln, r"\t")
end

datalines = filter(v -> length(v) > 1, parts)
txtlines = map(v -> v[2], datalines)
txtraw = join(txtlines," ")
txt1 = replace(txtraw, "·" => ":")

txt = replace(txt1, r"-[ ]*" => "")

using Orthography, PolytonicGreek

tkns = tokenize(txt, literaryGreek())

nopunct = filter(tkns) do t
    (t.tokencategory isa PunctuationToken) == false
end

tknstrings = map(nopunct) do tkn
    tkn.text
end

using StatsBase, OrderedCollections


counts = countmap(tknstrings) |> OrderedDict

sorted = sort(counts, byvalue=true, rev=true)

delimited = ["token|count"]
for k in keys(sorted)
    push!(delimited, string(k,"|", sorted[k]))
end

open(outfile, "w") do io
    write(io, join(delimited,"\n"))
end
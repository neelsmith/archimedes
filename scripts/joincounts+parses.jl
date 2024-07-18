parsesfile = joinpath(pwd(), "data", "parsecounts.cex")
tokensfile = joinpath(pwd(), "data", "tokensnormed.cex")

tokens  = readlines(tokensfile)[2:end] # skip header
parses = readlines(parsesfile)
@assert(length(tokens) == length(parses))


results = []
for (i,t) in enumerate(tokens)
    parsecount = split(parses[i],"|")[2]
    msg = parsecount == "0" ? t * "|no" : t * "|yes"
    push!(results, msg)
end

outfile = joinpath(pwd(), "data", "parseresults.cex")
open(outfile,"w") do io
    write(io, join(results,"\n"))
end
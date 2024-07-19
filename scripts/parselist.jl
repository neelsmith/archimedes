# "euclid-" or ""
prefix = "euclid-" 
# prefix = ""

#using Downloads
using CitableParserBuilder, CitableBase
using Kanones

parserurl = "http://shot.holycross.edu/morphology/attic_core-current.cex"
parser = kParser(parserurl, UrlReader)

countsfile = joinpath(pwd(), "data", "$(prefix)tokensnormed.cex")


lns = readlines(countsfile)[2:end]
tokens = map(lns) do ln
	split(ln, "|")[1]
end

parses = map(tokens) do t
	parsetoken(t, parser)
end
parsecounts = map(v -> length(v), parses)


summarylines =  ["token|count|parses"]
for (i,p) in enumerate(lns)
	msg = parsecounts[i] > 0 ? p * "|yes" : p * "|no"
	push!(summarylines, msg)
end

parseress = joinpath(pwd(), "data", "$(prefix)parseresults.cex")
open(parseress,"w") do io
	write(io, join(summarylines, "\n"))
end

failures = filter(ln -> endswith(ln,"|no"), summarylines)
failsfile = joinpath(pwd(), "data", "$(prefix)failures.cex")
open(failsfile,"w") do io
	write(io, join(failures,"\n"))
end

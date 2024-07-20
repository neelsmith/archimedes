using CitableParserBuilder, CitableBase
using Kanones

datadir = joinpath(pwd(), "data")

parserurl = "http://shot.holycross.edu/morphology/math-current.cex"
p = kParser(parserurl, UrlReader)

prefixes = Dict(
	:euclid => "euclid-",
	:archimedes => ""
)


function parselist(; parser = p,  text = :archimedes, prefixdict = prefixes, datadir = datadir)
	prefix = prefixdict[text]
	countsfile = joinpath(datadir, "$(prefix)tokensnormed.cex")
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

	parseress = joinpath(datadir, "$(prefix)parseresults.cex")
	open(parseress,"w") do io
		write(io, join(summarylines, "\n"))
	end

	failures = filter(ln -> endswith(ln,"|no"), summarylines)
	failsfile = joinpath(datadir, "$(prefix)failures.cex")
	open(failsfile,"w") do io
		write(io, join(failures,"\n"))
	end
end


parselist()
parselist(text = :euclid)












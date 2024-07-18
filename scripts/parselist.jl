using Downloads
using CitableParserBuilder
using Kanones

parserurl = "http://shot.holycross.edu/morphology/attic_core-current.cex"

function getremoteparser(u)
	tmp = Downloads.download(u)
	parser = Kanones.dfParser(tmp)
	rm(tmp)
	parser
end
parser = getremoteparser(parserurl)


countsfile = joinpath(pwd(), "data", "tokensnormed.cex")
lns = readlines(countsfile)[2:end]
tokens = map(lns) do ln
	split(ln, "|")[1]
end

parsetoken(tokens[1], parser)
#=
f = joinpath(pwd(),"tokencounts-sandc.cex")

wordlist = map(readlines(f)[2:end]) do ln
    split(ln,"|")[1]
end

parses = parsewordlist(wordlist, parser)

successes = filter(p -> ! isempty(p), parses)
=#
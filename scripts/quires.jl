# File names from Archimedes palimpsest project:
f = "palimpsest-images.txt"
raw = readlines(f)
basenames = map(s -> replace(s, ".tif" => ""), raw)

# Split up names following AP project naming convention:
parts = map(basenames) do s
    split(s, r"[_\-]")
end |> unique

# First three columns map palimpsest codex to original codex:
cols3 = map(v -> v[1:3], parts) |> unique
# except for the leaf in Cambridge
notcambridge = filter(v ->  v[1] != "cambridge", cols3) 
cambridge = filter(v -> v[1] == "cambridge", cols3)

archimmap = filter(v -> startswith(v[3], "Arch"), notcambridge) 
# 132 original folios:
archimfolios = map(v -> v[3], archimmap) |> unique

archimdict = Dict()
for folio in archimfolios
    archimdict[folio] = []
end
for triple in archimmap
    afolio = triple[3]
    prev = archimdict[afolio]
    @info("Afolio $(afolio): $(prev)")
    #push!(prev, join(triple[1:2], "-"))
    #archimdict[triple] = prev
end

using OrderedCollections
ordereddict = archimdict |> OrderedDict
sort!(ordereddict, byvalue=false)


# Check on the list of original texts:
map(v -> v[3][1:3], notcambridge) |> unique
f = "palimpsest-images.txt"

raw = readlines(f)
basenames = map(s -> replace(s, ".tif" => ""), raw)

parts = map(basenames) do s
    split(s, r"[_\-]")
end

parts[1]

cols3 = map(v -> v[1:3], parts)

notcambridge = filter(v ->  v[1] != "cambridge", cols3) 

filter(v -> v[1] == "cambridge", cols3)

filter(v -> ! startswith(v[3], "Arch"),notcambridge) 

map(v -> v[3][1:3], notcambridge) |> unique
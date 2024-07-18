f = joinpath(pwd(),"data", "rawtokencounts.cex")
datalines = filter(readlines(f)[2:end]) do ln
    ! isempty(ln)
end


function islabel(s)
    allcaps = true
    for c in s
        if islowercase(c) || Base.Unicode.category_string(c) == "Punctuation, other"
            allcaps = false
        end
    end
    allcaps
end


labelcounts = []
lexcounts = []

for ln in datalines
    cols = split(ln, "|")
    if islabel(cols[1])

        @info("Pushing $(ln) as label")
        push!(labelcounts, ln )    
    else
        push!(lexcounts, ln)
    end
end

labelfile = joinpath(pwd(), "data", "labelcounts.cex")
open(labelfile,"w") do io
    write(io, join(labelcounts,"\n"))
end
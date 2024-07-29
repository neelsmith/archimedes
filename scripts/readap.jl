using EzXML

src = joinpath(pwd(), "notes", "twopostulates.xml")
xmltext = read(src, String)
doc = parsexml(xmltext)


teins = "http://www.tei-c.org/ns/1.0"



xp = "/wrapper/ab"
divs = findall(xp, root(doc))

nwsrc = joinpath(pwd(), "palimpsest-project", "SphereAndCylinder-NW-p5.xml")
isfile(nwsrc)
nwxmltext = read(nwsrc, String)
nwdoc = parsexml(nwxmltext)


nwxp = "/ns:TEI/ns:text/ns:body/ns:div/ns:ab"

abv = findall(nwxp, root(nwdoc),["ns"=> teins])

elnames = []
for ab in abv
    for kid in eachelement(ab)
        push!(elnames, kid.name )
    end
end

elnames |> unique


figxp =  "/ns:TEI//ns:figure"
figv =  findall(figxp, root(nwdoc),["ns"=> teins])

using CitableTeiReaders
ezxmlstring.(figv)
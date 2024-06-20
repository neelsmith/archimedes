using EzXML
f = joinpath(pwd(), "palimpsest-project", "SandC1mod.xml")

sandc = readxml(f)

teins = "http://www.tei-c.org/ns/1.0"

mslist = findall("//ns:milestone", root(sandc), ["ns" => teins])


#divs = findall(xp, root(doc),["ns"=> teins])
#=
Analyze the TEI usage and contents of texts from the Archimedes Palimpsest project.
=#

using EzXML
f = joinpath(pwd(), "palimpsest-project", "SandC1mod.xml")
sandcroot = readxml(f) |> root

teins = "http://www.tei-c.org/ns/1.0"
sandcbody = findfirst("//ns:body", sandcroot,["ns" => teins])


# Usage: TEI elements used

"""Collect all element names."""
function eleminventory(el, elnames = []; tier = 1)
    namelist = elnames
    for kid in eachnode(el)
        #@info(string("(type " , nodetype(kid), ")" ))
        if nodetype(kid) == EzXML.ELEMENT_NODE	
            #@info("$(tier). $(nodename(kid))")
            newtier = tier + 1
            
            if nodename(kid) == "w"
                #@info("Look at $(attributes(kid))")
            end

            if nodename(kid) in namelist
                namelist = eleminventory(kid, namelist; tier = newtier)
            else
                newlist = push!(namelist, nodename(kid))
                namelist = eleminventory(kid, newlist; tier = newtier)

            end
        elseif nodetype(kid) == EzXML.TEXT_NODE	
            #@info("$(nodecontent(kid))")
        end
    end
    namelist
end


elnames = eleminventory(sandcbody)
open(joinpath("data", "apusage.txt"), "w") do io
    write(io, join(elnames,"\n"))
end


# Usage: choice

"""Find all descendants of `choice` elements."""
function choices(el, opts = [])
    choicekids = opts
    for kid in eachnode(el)
        if nodetype(kid) == EzXML.ELEMENT_NODE	
            if nodename(kid) == "choice"
                for elname in showme(kid)
                    if ! (elname in choicekids)
                        push!(choicekids, elname)
                    end
                end
            else
                choicekids = choices(kid, choicekids)
            end
        end
    end
    choicekids
end



choicedescendants = choices(sandcbody)
open(joinpath("data","apchoices.txt"), "w") do io
    write(io, join(choicedescendants,"\n"))
end




# Other things to collect...

mslist = findall("//ns:milestone", sandcroot, ["ns" => teins])

figdescxp = "//ns:figDesc"
figdescv = findall(figdescxp, sandcroot,["ns"=> teins])
eleminventory(figdescv[1])


### WOrk on a small sample:
src = joinpath(pwd(), "notes", "twopostulates.xml")
doc  = readxml(src)
xp = "/wrapper/ab"
abdivs = findall(xp, root(doc))


# Don't forget how to use this

using CitableTeiReaders
ezxmlstring.(figv)


## 


## Test a section
hdrxml = """<head>
					<milestone n="Arch45r" unit="underTextFolio"/><milestone n="109r2" unit="folio"/>
					<lb n="1"/>ΑΡΧΙΜΗΔΟΥΣ <choice>
						<abbr></abbr>
						<expan><ex>ΠΕΡΙ</ex></expan>
					</choice>
					<choice>
						<abbr>Τ</abbr>
						<expan>Τ<ex>ΗΣ</ex></expan>
					</choice>
					<lb n="2"/>ΣΦΑΙΡΑΣ <choice>
						<abbr></abbr>
						<expan><ex>ΚΑΙ</ex></expan>
					</choice>
					<w part="I"><choice>
							<abbr>ΚΥΛΙ</abbr>
							<expan>ΚΥΛΙ<ex>Ν</ex></expan>
						</choice></w>
					<lb n="3"/><w part="F">ΔΡΟΥ</w>
				</head>
"""

hdr = parsexml(hdrxml) |> root

textfragg(hdr)

textfragg(hdr; edition = :diplomatic)
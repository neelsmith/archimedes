using EzXML
using Markdown

src = joinpath(pwd(), "notes", "twopostulates.xml")
#xmltext = read(src, String)
#doc = parsexml(xmltext)
doc  = readxml(src)

teins = "http://www.tei-c.org/ns/1.0"

# EzXML.TEXT_NODE

xp = "/wrapper/ab"
divs = findall(xp, root(doc))


function showme(el, elnames = []; tier = 1)
    namelist = elnames
    for kid in eachnode(el)
        #@info(string("(type " , nodetype(kid), ")" ))
        if nodetype(kid) == EzXML.ELEMENT_NODE	
            @info("$(tier). $(nodename(kid))")
            newtier = tier + 1
            
            if nodename(kid) == "w"
                @info("Look at $(attributes(w))")
            end

            if nodename(kid) in namelist
                namelist = showme(kid, namelist; tier = newtier)
            else
                newlist = push!(namelist, nodename(kid))
                namelist = showme(kid, newlist; tier = newtier)

            end
        elseif nodetype(kid) == EzXML.TEXT_NODE	
            @info("$(nodecontent(kid))")
        end
    end
    namelist
end


showme(divs[2])



INITIIAL_W = "I"
FINAL_W = "F"
function mdfragg(el, textpieces = [], hanging = "")
    fragg = textpieces
    for kid in eachnode(el)
        if nodename(kid) == "w"
            childtext = mdtext(kid)
            if kid["part"] == FINAL_W
                str = hanging * "||" * childtext
                hanging = ""
                @info("SPLITTER: $(str)")
                push!(fragg, str)
            elseif kid["part"] == INITIIAL_W
                hanging = childtext 
            end
        elseif nodename(kid) == "lb" && isempty(hanging)
            push!(fragg, " || ")

        elseif nodetype(kid) == EzXML.ELEMENT_NODE	
            #@info("$(nodename(kid))")
            fragg = mdfragg(kid, fragg)

            
        elseif nodetype(kid) == EzXML.TEXT_NODE	

            rational = replace(nodecontent(kid), r"\s+" => " ")
            push!(fragg, rational)
            fragg = mdfragg(kid, fragg)
        end
    end
    fragg
end

function mdtext(el)
    raw = join(mdfragg(el))
    replace(raw, r"\s+" => " ") |> strip
end



mdfragg(divs[2])|> join |> Markdown.parse



mdtext(divs[2])





function wbreaks(el)
    
    for kid in eachnode(el)
        if nodetype(kid) == EzXML.ELEMENT_NODE	
            if nodename(kid) == "w"
                @info(kid["part"])
                #for a in eachattribute(kid)
                #    @info(nodename(a))
                #end
            end
        end
    end
end


wbreaks(divs[2])



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

choices(divs[2])

nwsrc = joinpath(pwd(), "palimpsest-project", "SphereAndCylinder-NW-p5.xml")
isfile(nwsrc)
#nwxmltext = read(nwsrc, String)
nwdoc = readxml(nwsrc)

nwroot = root(nwdoc)
nwbody = findfirst("//ns:body", nwroot, ["ns" => teins])
nwtei = showme(nwbody)


open("nwusage.txt", "w") do io
    write(io, join(nwtei,"\n"))
end


choicedescendants = choices(nwbody)
open("nwchoices.txt", "w") do io
    write(io, join(choicedescendants,"\n"))
end


figdescxp = "//ns:figDesc"
figdescv = findall(figdescxp, nwroot,["ns"=> teins])
showme(figdescv[1])

ignore = ["figure",
"figDesc"]


nwxp = "/ns:TEI/ns:text/ns:body/ns:div/ns:ab"

abv = findall(nwxp, nwroot,["ns"=> teins])

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
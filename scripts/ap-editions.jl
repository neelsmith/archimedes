#=
Convert XML of AP XML to plain-text editions.
=#

using EzXML
using Markdown
using CitableBase, CitableText, CitableCorpus
using GreekScientificOrthography

teins = "http://www.tei-c.org/ns/1.0"

INITIAL_W = "I"
FINAL_W = "F"
LB = "/"


"""Look up value of attribute `aname` in node `n`.
"""
function attrval(n::EzXML.Node, aname::AbstractString)
    rslt = nothing
    for a in eachattribute(n)
        if nodename(a) == aname
            rslt = nodecontent(a)
        end
    end
    rslt
end

"""Collect a vector of text fragments with correct white spacing
for a plain-text edition.
"""
function textfragg(el::EzXML.Node, textpieces = AbstractString[], hanging = ""; edition = :expanded)
    
    fragg = textpieces
    for kid in eachnode(el)
        if nodename(kid) == "w"
            childtext = textedition(kid, edition)

            if attrval(kid, "part") == FINAL_W
                str = hanging * LB * childtext
                hanging = ""
                #@info("SPLITTER: $(str)")
                push!(fragg, str)

            elseif attrval(kid, "part") == INITIAL_W
                hanging = childtext 
            end
        elseif nodename(kid) == "lb" && isempty(hanging)
            push!(fragg, " $(LB) ")

        elseif nodename(kid) == "abbr" && edition == :expanded
            #@info("Skip abbreviated with editino $(edition)")
            # skip it


        elseif nodename(kid) == "expan" && edition == :diplomatic
            #@info("Skip expanded with edition = $(edition)")
            # skip it


        elseif nodename(kid) == "num"
            s = textedition(kid, edition) * NUMERIC_TICK
            push!(fragg, s)

        elseif nodename(kid) == "g"
            @info("Flagging symbolic glyph")
            push!(fragg,"🧩")


        elseif nodename(kid) == "supplied"
            s = "[" * textedition(kid, edition) * "]"
            push!(fragg, s)

        elseif nodename(kid) == "unclear"
            s = "*" * textedition(kid, edition) * "*"
            push!(fragg, s)

        elseif nodename(kid) == "del"
            s = "〖" * textedition(kid, edition) * "〗"
            push!(fragg, s)            

        elseif nodename(kid) == "sic"
            s = "{" * textedition(kid, edition) * "}"
            push!(fragg, s) 

        #elseif nodename(kid) == "ex"            
        #    extext = textedition(kid, edition)            
        #    push!(fragg,"$(extext)")

        elseif nodetype(kid) == EzXML.ELEMENT_NODE	
            #@info("$(nodename(kid)) in edition $(edition)")
            fragg = textfragg(kid, fragg; edition = edition)

            
        elseif nodetype(kid) == EzXML.TEXT_NODE	

            rational = replace(nodecontent(kid), r"\s+" => " ")
            push!(fragg, rational)
            fragg = textfragg(kid, fragg; edition = edition)
        end
    end
    fragg
end

"""Collect a single plain-text edition of a given XML element.
"""
function textedition(el::EzXML.Node, edition = :expanded)
    raw = join(textfragg(el; edition = edition))
    replace(raw, r"\s+" => " ") |> strip
end

f = joinpath(pwd(), "palimpsest-project", "SandC1mod.xml")
sandcroot = readxml(f) |> root

"""Create a CTS edition from AP project XML source.
- Walk the tree in 3 citation tiers.
"""
function citableAP(docroot::EzXML.Node, edition = :expanded; delimiter = "|", blockheader = true)
    datalines = []
    baseurn = "urn:cts:greekLit:tlg0552.tlg001.ap:"
    bks = findall("/ns:TEI/ns:text/ns:body/ns:div", docroot, ["ns" => teins])

    for bk in bks
        bkid = bk["n"]
        divlevel = findall("ns:div", bk, ["ns" => teins])
        for d in divlevel
            divid = d["n"]
            for a in findall("ns:ab", d, ["ns" => teins])
                abid = a["n"]
                ref = baseurn * join([bkid, divid, abid], ".")
                txt = textedition(a, edition)
                push!(datalines, join([ref, txt], delimiter))

            end
        end
    end
    blockheader ? "#!ctsdata\n" * join(datalines, "\n") : join(datalines, "\n")
    
end

sandc_editorial_txt = citableAP(sandcroot)
sandc_diplomatic_txt = citableAP(sandcroot, :diplomatic)

sandc_editorial = fromcex(sandc_editorial_txt, CitableTextCorpus)
sandc_diplomatic = fromcex(sandc_diplomatic_txt, CitableTextCorpus)

open(joinpath("texts", "SandC-ap-diplomatic.cex"), "w") do io
    write(io, sandc_diplomatic_txt)
end

open(joinpath("texts", "SandC-ap-editorial.cex"), "w") do io
    write(io, sandc_editorial_txt)
end




### Test pieces:

#=
sandcbody = findfirst("//ns:body", sandcroot,["ns" => teins])

dipl = textedition(sandcbody, :diplomatic)
editorial = textedition(sandcbody, :expanded)


pen(joinpath("data", "ap-dipl.txt"), "w") do io
    write(io, dipl)
end

open(joinpath("data", "ap-editorial.txt"), "w") do io
    write(io, editorial)
end
=#
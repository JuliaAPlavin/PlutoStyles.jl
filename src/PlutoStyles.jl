module PlutoStyles

export Pluto

import Pluto


full_content(x::Nothing, path) = read(path, String)
is_match(x, str) = occursin(x.regex, str)
is_match(x::Nothing, str) = true

struct ReplaceFile
    regex::Regex
    new_path::String
end

full_content(x::ReplaceFile, path) = read(x.new_path, String)

struct AddToFile
    regex::Regex
    content::String
    position::Union{typeof(first), typeof(last)}
end

full_content(x::AddToFile, path) = x.position == first ? x.content * read(path, String) : read(path, String) * x.content

overrides() = [
    AddToFile(r"/Pluto/\w+/frontend/editor.css$", """
    /* occupy full width */
    main {
        max-width: calc(100% - 2em) !important;
        margin-left: 1em !important;
        margin-right: 1em !important;
    }

    /* larger images in arrays when expanded */
    pluto-tree img {
        max-width: none !important;
        max-height: none !important;
    }

    /* somewhat larger images in arrays when collapsed */
    pluto-tree.collapsed img {
        max-width: 15rem !important;
        max-height: 15rem !important;
    }

    /* limit width & wrap long types - common for tables */
    jltree > jlprefix.long {
        max-width: 250px;
        overflow-wrap: break-word;
        white-space: normal;
    }

    /* purely cosmetic */
    #helpbox-wrapper {
        opacity: 0.85;
    }
    """, first),
    AddToFile(r"/Pluto/\w+/frontend/index.css$", """
    li.recent > a:after, li.running > a:after {
        display: block;
        content: attr(title);
        font-size: x-small;
    }

    li > a[title*="/pluto_notebooks/"] {
        color: rgb(16 113 109);
    }
    """, first),
    nothing
]

# original version copied from https://github.com/fonsp/Pluto.jl/blob/main/src/webserver/Static.jl
function Pluto.asset_response(path)
    if !isfile(path) && !endswith(path, ".html")
        return asset_response(path * ".html")
    end
    try
        @assert isfile(path)
        override = first(filter(o -> is_match(o, path), overrides()))
        response = Pluto.HTTP.Response(200, full_content(override, path))
        m = Pluto.mime_fromfilename(path)
        push!(response.headers, "Content-Type" => Base.istextmime(m) ? "$(m); charset=UTF-8" : string(m))
        push!(response.headers, "Access-Control-Allow-Origin" => "*")
        response
    catch e
        @show path e
        Pluto.HTTP.Response(404, "Not found!")
    end
end

end

module PlutoStyles

export Pluto

import Pluto


full_content(x::Nothing, data) = data
is_match(x, str) = occursin(x.regex, str)
is_match(x::Nothing, str) = true

struct ReplaceFile
    regex::Regex
    new_path::String
end

full_content(x::ReplaceFile, data) = read(x.new_path, String)

struct AddToFile
    regex::Regex
    content::String
    position::Union{typeof(first), typeof(last)}
end

full_content(x::AddToFile, data) = x.position == first ? x.content * data : data * x.content

overrides() = [
    AddToFile(r"/Pluto/\w+/frontend-dist/editor(|\.\w+).css$", """
    /* occupy full width */
    body > main {
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

    /* move cell popup menu to the left of its button */
    pluto-input > .open.input_context_menu > ul {
        left: calc(100% - var(--width) - 36px) !important;
    }
    pluto-input > .open.input_context_menu > ul, pluto-input > .open.input_context_menu {
        z-index: 31 !important;
    }
    """, first),
    AddToFile(r"/Pluto/\w+/frontend-dist/index(|\.\w+).css$", """
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
function Pluto.asset_response(path; cacheable::Bool=false)
    if !isfile(path) && !endswith(path, ".html")
        return Pluto.asset_response(path * ".html"; cacheable)
    end
    if isfile(path)
        data = read(path, String)
        override = first(filter(o -> is_match(o, path), overrides()))
        @debug "" path override
        response = Pluto.HTTP.Response(200, full_content(override, data))
        m = Pluto.mime_fromfilename(path)
        push!(response.headers, "Content-Type" => Base.istextmime(m) ? "$(m); charset=UTF-8" : string(m))
        push!(response.headers, "Access-Control-Allow-Origin" => "*")
        # don't add content-length and cache-control headings
        response
    else
        @warn "404" path
        Pluto.HTTP.Response(404, "Not found!")
    end
end

# taken with modification from
# https://discourse.julialang.org/t/ann-plutostyles-jl-override-styles-of-pluto-notebooks/64280/9
function run(args...; kwargs...)
    if length(ARGS) > 0
        notebook = ARGS[1]
        Pluto.run(args...; notebook=abspath(notebook), kwargs...)
    else
        Pluto.run(args...; kwargs...)
    end
end

end

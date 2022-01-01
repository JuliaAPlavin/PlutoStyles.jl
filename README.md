# PlutoStyles.jl

Add the ability to override CSS styles of Pluto.jl notebooks - or any other static Pluto asset, really.

Styles I use myself get applied by default:

```julia
julia> using PlutoStyles

julia> Pluto.run()
```
See the package source code for the actual CSS.

Arbitrary overrides are possible:

```julia
julia> PlutoStyles.overrides() = [
    PlutoStyles.AddToFile(r"/Pluto/\w+/frontend/editor.css$", """
    ... raw CSS content to add to editor.css ...
    """, first),  # first: prepend to original file; last: append to original
    PlutoStyles.ReplaceFile(r"/Pluto/\w+/frontend/editor.css$", "new/path/to/editor.css"),  # completely replace the original file
]

julia> Pluto.run()
```

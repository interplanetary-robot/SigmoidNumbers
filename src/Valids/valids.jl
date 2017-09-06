
include("constants.jl")
include("properties.jl")
include("dedekind.jl")  #dedekind cuts and the like.
include("h-layer.jl")
include("rounding.jl")
include("convert.jl")

#empty constructor
(::Type{Valid{N,ES}}){N,ES}() = Valid{N,ES}(reinterpret(Vnum{N,ES}, zero(@UInt)), reinterpret(Vnum{N,ES}, zero(@UInt)))

include("macros.jl")
include("addsub.jl")
include("mul.jl")
include("div.jl")

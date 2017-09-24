using SigmoidNumbers
using Base.Test


#println(*(Exact{4,0}(0b1000) → Exact{4,0}(0b1000), Exact{4,0}(0b1000) → Exact{4,0}(0b1000)))


include("h-layer-test.jl")
include("breakdown-test.jl")

include("Posits5-test.jl")
include("Posits7-test.jl")

include("misc-test.jl")

include("fdp-test.jl")

#include("fdp-matrix-test.jl")

#tests for the valids
include("warlpiri-test.jl")

using SigmoidNumbers
using Base.Test

*(Exact{4,0}(0b0100) → ULP{4,0}(0b1101),ULP{4,0}(0b0111) → Exact{4,0}(0b1000)) |> println
exit()

include("h-layer-test.jl")
include("breakdown-test.jl")

include("Posits5-test.jl")
include("Posits7-test.jl")

include("misc-test.jl")

include("fdp-test.jl")

#include("fdp-matrix-test.jl")

#tests for the valids
include("warlpiri-test.jl")

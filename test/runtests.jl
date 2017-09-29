using SigmoidNumbers
using Base.Test

#*(ULP{4,0}(0b1001) → ULP{4,0}(0b1011), Exact{4,0}(0b1110) → ULP{4,0}(0b1011)) |> println
#exit()

include("h-layer-test.jl")
include("breakdown-test.jl")

include("Posits5-test.jl")
include("Posits7-test.jl")

include("misc-test.jl")
include("fdp-test.jl")

#include("fdp-matrix-test.jl")

#tests for the valids
include("warlpiri-test.jl")

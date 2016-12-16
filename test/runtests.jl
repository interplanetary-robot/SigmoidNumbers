using SigmoidNumbers
using Base.Test

#=
M7 = MLSigmoid{7}
@test Float64(M7(-16.0) + M7(12.0)) == 4.0
=#

include("MLSigmoid5-test.jl")
include("MLSigmoid7-test.jl")

using SigmoidNumbers
using Base.Test


M7 = Posit{7}
@test Float64(M7(2.25) / M7(0.09375)) == 16.0
#=
P7 = Posit{7}
v1 = P7(30.0)
v2 = P7(5.0)

println(Float64(v1/v2))
=#

include("Posits5-test.jl")
include("Posits7-test.jl")

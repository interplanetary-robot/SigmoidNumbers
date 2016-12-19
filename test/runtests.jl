using SigmoidNumbers
using Base.Test

#=
M7 = Posits{7}
@test Float64(M7(-16.0) + M7(12.0)) == 4.0

P7 = Posits{7}
v1 = P7(30.0)
v2 = P7(5.0)

println(Float64(v1/v2))
=#

include("Posits5-test.jl")
include("Posits7-test.jl")

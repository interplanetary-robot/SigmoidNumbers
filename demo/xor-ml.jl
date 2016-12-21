#xor-ml.jl - set up to test the xor function in julia.

using SigmoidNumbers
using GenML
using Base.Test

P8 = Posits{8}

xornet = GenML.MLP.MultilayerPerceptron{P8, (2,2,1)}()

#hand-written transition matrices.
xornet.transitions[1] = P8[-7.5 5.0 5.0; 7.5 -10.0 -10.0]
xornet.transitions[2] = P8[5.0 -10.0 -10.0]

#test the possible input/output pairs.

#assign sigmoid to the pseudologistic
GenML.sigmoid(x::Posits) = SigmoidNumbers.pseudologistic(x)

@test xornet([true, true])[1] < P8(0.5)
@test xornet([true, false])[1] > P8(0.5)
@test xornet([false, true])[1] > P8(0.5)
@test xornet([false, false])[1] < P8(0.5)

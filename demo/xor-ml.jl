#xor-ml.jl - set up to test the xor function in julia.

using SigmoidNumbers
using GenML
using Base.Test

if length(ARGS) > 0
  PType = Posit{parse(ARGS[1])}
else
  PType = Posit{12}
end

#assign sigmoid to the pseudologistic
GenML.TF.sigmoid(x::Posit) = SigmoidNumbers.pseudologistic(x)
GenML.TF.dasysigmoid(x::Posit) = SigmoidNumbers.delta_psl(x)
GenML.CF.logloss(x::Posit) = SigmoidNumbers.pseudologcost(x)

xornet = GenML.MLP.MultilayerPerceptron{PType, (2,2,1)}()

#hand-written transition matrices.
xornet.layers[1].transition = PType[5.0 5.0; -10.0 -10.0]
xornet.layers[1].bias[:] = PType[-7.5, 7.5]
xornet.layers[2].transition = PType[-10.0 -10.0]
xornet.layers[2].bias[:] = PType[5.0]

#test the possible input/output pairs.

println("attempting premade xor neural net, with posit $PType")

@test xornet([true, true])[1] < PType(0.5)
@test xornet([true, false])[1] > PType(0.5)
@test xornet([false, true])[1] > PType(0.5)
@test xornet([false, false])[1] < PType(0.5)

println("execution of premade xor neural net successful with $PType")

println("attempting to train xor neural net, with posit $PType")

Base.randn(::Type{PType}, dims::Integer...) = map(PType, randn(dims...))

function xortrain()

  println("working on unreliable xor data set with backpropagation")

  input_matrix = rand(Bool, 10, 500)
  training_results = Array{Bool,2}(1,500)
  training_results[:] = [input_matrix[1, col] $ input_matrix[2, col] $ (rand() < 0.05) for col in 1:size(input_matrix,2)]

  xornet = GenML.MLP.MultilayerPerceptron{PType,(10,2,1)}(randn)

  for rounds = 1:25
  for idx = 1:500
    input_column = input_matrix[:, idx]
    training_column = training_results[:, idx]

    GenML.MLP.backpropagationoptimize(xornet, input_column, training_column, GenML.CF.crossentropy)
  end
  end

  #verify that the optimization has resulted in a good data set.
  wrongcount = 0
  for x = 1:50
    input_vector = rand(Bool, 10)
    wrongcount += (xornet(input_vector)[1] > PType(0.5)) != (input_vector[1] $ input_vector[2])
  end
  println("incorrect responses for noisy xor: $wrongcount / 50 => $(2 * (50 - wrongcount)) % correct")

  return wrongcount
end

xortrain() == 0 || xortrain() == 0 || xortrain() == 0 || xortrain() == 0 || xortrain() == 0 || xortrain() == 0 || xortrain() == 0 || xortrain() == 0

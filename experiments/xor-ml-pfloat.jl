#xor-ml.jl - set up to test the xor function in julia.

using SigmoidNumbers
using GenML

import SigmoidNumbers.Sigmoid

#assign sigmoid to the pseudologistic
GenML.TF.sigmoid(x::Posit) = SigmoidNumbers.pseudologistic(x)
GenML.TF.dasysigmoid(x::Posit) = SigmoidNumbers.delta_psl(x)
GenML.CF.logloss(x::Posit) = SigmoidNumbers.pseudologcost(x)

function xortrain(PType)

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

Base.randn{PType <: Sigmoid}(::Type{PType}, dims::Integer...) = map(PType, randn(dims...))


const trials = 1000

for nindex = 16:-1:6
  results = zeros(Int, trials)

  PType = Posit{nindex}

  for idx = 1:trials
    println("posit $(PType): round $idx")
    results[idx] = xortrain(PType)
  end

  writedlm(string("./results/posit-widened-$nindex.csv"), results, ',')
end

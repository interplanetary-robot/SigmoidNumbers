#xor-ml.jl - set up to test the xor function in julia.

using GenML
using AltFP

Base.randn{PType <: SmallFloat}(::Type{PType}, dims::Integer...) = map(PType, randn(dims...))

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

const trials = 1000

for nindex = 16:-1:6
  for vindex = (nindex - 2):-1:1
    PType = SmallFloat{nindex, vindex}

    results = zeros(Int, trials)
    for idx = 1:trials
      println("$(PType): round $idx")
      results[idx] = xortrain(PType)
    end

    writedlm(string("./results/smallfloat-$nindex-$vindex.csv"), results, ',')
  end
end

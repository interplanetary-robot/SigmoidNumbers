#xor-ml.jl - set up to test the xor function in julia.

using SigmoidNumbers
using GenML

import GenML.FCL: FullyConnectedLayer, matrixfma, dxasychainrule, scaledsubtract, scaledouterproductfma, reversematrixfma
import GenML.MLP: MultilayerPerceptron
import GenML.dxasy
import GenML.VoidableDeltas
import GenML.BackpropStorage
import GenML.backpropagate!
import GenML.evaluate!

import SigmoidNumbers.Sigmoid
import SigmoidNumbers.__round

GenML.TF.sigmoid(x::Posit) = SigmoidNumbers.pseudologistic(x)
GenML.TF.dasysigmoid(x::Posit) = SigmoidNumbers.delta_psl(x)
GenML.CF.logloss(x::Posit) = SigmoidNumbers.pseudologcost(x)

const clamplist = Symbol[]

#populate the clamplist using values from the command line
__print = false
all = false
count = 100
for arg in ARGS
  if arg == "print"
    __print = true
    count = 1
  end
  if arg == "all"
    all = true
  end
  push!(clamplist, Symbol(arg))
end

#create a "clamping" macro that will clamp values of an array down to a lower posit,
#givn an identifier saying we should clamp this.
macro clamp(value, identifier)

  extracted_symbol = identifier.args[1]

  pstmt = __print ? :(println($value)) : :()

  if all || (extracted_symbol in clamplist)
    esc(quote
      $pstmt
      if isa($value, AbstractArray)
        for idx = 1:length($value)
          if isa($value[idx], Posit)
            temp = reinterpret(Posit{8}, $value[idx])
            temp = SigmoidNumbers.__round(temp)
            $value[idx] = reinterpret(F, temp)
          end
        end
      else
        temp = reinterpret(Posit{8}, $value)
        temp = SigmoidNumbers.__round(temp)
        $value = reinterpret(F, temp)
      end
      $pstmt
    end)
  end
end

__print && println(clamplist)
################################################################################

function GenML.FCL.matrixfma{F<:Posit}(output, mtx, input::AbstractVector{F}, bias, isize, osize)
  for idx = 1:osize
    @inbounds output[idx] = bias[idx]

    @clamp output[idx] :matrixfma_acc

    @inbounds for jdx = 1:isize

      matrixfma_product = mtx[idx, jdx] * input[jdx]

      @clamp matrixfma_product :matrixfma_prod

      output[idx] += matrixfma_product

      @clamp output[idx] :matrixfma_acc
    end
  end
end

################################################################################

function GenML.FCL.reversematrixfma{F<:Posit}(input_array::AbstractVector{F}, matrix::AbstractMatrix{F}, output_array::AbstractVector{F}, i, o)
  for idx = 1:i
      input_array[idx] = zero(F)

      @clamp input_array[idx] :reversematrixfma_acc

    for jdx = 1:o

      reversematrixfma_product = matrix[jdx, idx] * output_array[jdx]

      @clamp reversematrixfma_product :reversematrixfma_prod

      input_array[idx] += reversematrixfma_product

      @clamp input_array[idx] :reversematrixfma_acc

    end
  end
end

function GenML.FCL.scaledouterproductfma{F<:Posit}(matrix::AbstractMatrix{F}, output_deltas::AbstractVector{F}, input_array::AbstractVector, alpha::F, i, o)
  for idx = 1:o
    for jdx = 1:i

      scaledouterproductfma_prod = alpha * (output_deltas[idx] * input_array[jdx])

      @clamp scaledouterproductfma_prod :scaledouterproductfma_prod

      matrix[idx,jdx] -= scaledouterproductfma_prod # + lambda * mlp.transitions[l_idx - 1])

      @clamp matrix[idx,jdx] :scaledouterproductfma_acc
    end
  end
end


function GenML.FCL.scaledsubtract{F<:Posit}(target_vector::AbstractVector{F}, value_vector::AbstractVector{F}, alpha::F, o)
  for idx = 1:o
    target_vector[idx] -= alpha * value_vector[idx]

    @clamp target_vector[idx] :scaledsubtract
  end
end


function GenML.FCL.dxasychainrule{F<:Posit}(outer_differential::AbstractVector{F}, inner_value::AbstractVector{F}, f::Function, o)
  for idx = 1:o
    outer_differential[idx] = outer_differential[idx] .* (dxasy(f))(inner_value[idx])

    @clamp outer_differential[idx] :dxasychainrule
  end
end

################################################################################

#MONKEY PATCH MLP BACKPROPAGATION ALGO TO HAVE CLAMPS EVERYWHERE
#implementation of the backpropagation algorithm for multilayer perceptrons.
@generated function backpropagate!{F <: Posit, i, o, tf}(fcl::FullyConnectedLayer{F, i, o, tf},
#==#                                            input::AbstractArray,
#==#                                            output::AbstractArray{F},
#==#                                            output_deltas::AbstractArray{F},
#==#                                            input_deltas::VoidableDeltas{F} = nothing)

  code = quote
    #for now.
    const alpha = F(0.1)

    @clamp input         :backprop_input
    @clamp output        :backprop_output
    @clamp output_deltas :backprop_output_deltas

    #overwrite the output delta values with the adjusted values taking the
    dxasychainrule(output_deltas, output, tf, o)

    @clamp output_deltas :backprop_output_transition

    scaledsubtract(fcl.bias, output_deltas, alpha, o)

    scaledouterproductfma(fcl.transition, output_deltas, input, alpha, i, o)
  end

  (input_deltas == Void) && return code

  #handle the backpropagating delta data.
  quote
    $code
    reversematrixfma(input_deltas, fcl.transition, output_deltas, i, o)

    @clamp input_deltas :backprop_input_deltas
  end
end

################################################################################

function evaluate!{F <: Posit, i, o, tf}(output::AbstractArray{F}, fcl::FullyConnectedLayer{F, i, o, tf}, input::AbstractArray)

  @clamp input :evaluate_input

  matrixfma(output, fcl.transition, input, fcl.bias, i, o)

  @clamp output :evaluate_transition

  for idx = 1:o
    output[idx] = tf(output[idx])
  end

  @clamp output :evaluate_output
end

################################################################################

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

    GenML.Optimizers.backpropagationoptimize(xornet, input_column, training_column, GenML.CF.crossentropy)
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

const trials = count

results = zeros(Int, trials)
PType = Posit{16}

for idx = 1:trials
  println("posit $(PType): round $idx")
  results[idx] = xortrain(PType)
end

println("result: ", sum(results) / trials)

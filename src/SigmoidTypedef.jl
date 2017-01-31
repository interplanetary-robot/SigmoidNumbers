#sigmoid typedef - type definition for sigmoid-valued numbers.
#environment bits parameter.

#for now, put this here
__sigmoid_settings = Dict{Symbol, Any}()
getsetting(k) = haskey(__sigmoid_settings, k) ? __sigmoid_settings[k] : nothing

if (Int == Int32) || getsetting(:basebits) == 32
  const __BITS = 32
elseif getsetting(:basebits) == 16
  const __BITS = 16
elseif getsetting(:basebits) == 8
  const __BITS = 8
else #default to a 64-bit environment.
  const __BITS = 64
end

bitstype __BITS Sigmoid{N, ES, mode} <: AbstractFloat

#_N{N, ES, mode}(::Type{Sigmoid{N,ES,mode}})          = N
#_ES{N, ES, mode}(::Type{Sigmoid{N,ES,mode}})         = ES
#_mode{N, ES, mode}(::Type{Sigmoid{N,ES,mode}})       = mode

#these are deliberately made incompatible with the standard rounding modes types
#found in the julia std library.

const roundingmodes = [:guess,
  :ubit,
  :roundup,
  :rounddn,
  :roundin,
  :roundout]

#uses the rounding mode types:
typealias Posit{N, ES} Sigmoid{N, ES, :guess}

typealias Vnum{N, ES} Sigmoid{N, ES, :ubit}
typealias Exact{N, ES} Vnum{N, ES}
typealias ULP{N, ES} Vnum{N, ES}

immutable Valid{N, ES} <: AbstractFloat
  lower::Vnum{N, ES}
  upper::Vnum{N, ES}
end

export Sigmoid, Posit, Valid, Exact, ULP

#sigmoid numbers don't natively have NaN, so NaNs should all be noisy.
type NaNError <: Exception
  operand::Function
  parameters::Array{Any,1}
end

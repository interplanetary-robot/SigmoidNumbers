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

bitstype __BITS Sigmoid{N, mode} <: AbstractFloat

typealias MLSigmoid{N} Sigmoid{N, :MLrounding}
typealias UBSigmoid{N} Sigmoid{N, :Ubits}

type SigBound{N} <: AbstractFloat
  lower::UBSigmoid{N}
  upper::UBSigmoid{N}
end

export MLSigmoid
export UBSigmoid
export SigBound

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

abstract Sigmoid{N, ES, mode} <: AbstractFloat

bitstype __BITS SigmoidSmall{N, ES, mode} <: Sigmoid{N, ES, mode}
immutable       SigmoidLarge{N, ES, mode} <: Sigmoid{N, ES, mode}
  bits::Array{Int64, 1}
end

N{_N, ES, mode}(::Type{Sigmoid{_N,ES,mode}})          = _N
N{_N, ES, mode}(::Type{SigmoidSmall{_N,ES,mode}})     = _N
N{_N, ES, mode}(::Type{SigmoidLarge{_N,ES,mode}})     = _N
ES{N, _ES, mode}(::Type{Sigmoid{N,_ES,mode}})         = _ES
ES{N, _ES, mode}(::Type{SigmoidSmall{N,_ES,mode}})    = _ES
ES{N, _ES, mode}(::Type{SigmoidLarge{N,_ES,mode}})    = _ES
mode{N, ES, _mode}(::Type{Sigmoid{N,ES,_mode}})       = _mode
mode{N, ES, _mode}(::Type{SigmoidSmall{N,ES,_mode}})  = _mode
mode{N, ES, _mode}(::Type{SigmoidLarge{N,ES,_mode}})  = _mode

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
typealias Valid{N, ES} Sigmoid{N, ES, :ubit}

type VBound{N, ES} <: AbstractFloat
  lower::Valid{N, ES}
  upper::Valid{N, ES}
end

export Sigmoid, Posit, Valid, VBound

################################################################################
# aliasing constructors

function (::Type{Posit{N, ES}}){N, ES}(x)
  if N < __BITS
    reinterpret(SigmoidSmall{N, ES, :guess}, x)
  else
    SigmoidLarge{N, ES, :guess}(x)
  end
end

function (::Type{Valid{N, ES}}){N, ES}(x)
  if N < __BITS
    reinterpret(SigmoidSmall{N, ES, :ubit}, x)
  else
    SigmoidLarge{N, 0, :ubit}(x)
  end
end

function (::Type{Sigmoid{N, ES, mode}}){N, ES, mode}(x)
  if N < __BITS
    reinterpret(SigmoidSmall{N, 0, :ubit}, x)
  else
    SigmoidLarge{N, 0, :ubit}(x)
  end
end
